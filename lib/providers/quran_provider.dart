import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';
import '../models/hafiz_model.dart';
import '../models/favorite_ayah_model.dart';
import '../core/services/quran_service.dart';
import '../core/constants/quran_surahs_data.dart';

class QuranProvider extends ChangeNotifier {
  List<SurahModel> _surahList = List.from(kAllSurahs);
  SurahModel? _currentSurah;
  List<AyahModel> _ayahs = [];
  List<FavoriteAyahModel> _favorites = [];
  bool _isLoadingSurahs = false;
  bool _isLoadingAyahs = false;
  String _errorMessage = '';

  HafizModel _selectedHafiz = HafizList.reciters.first; // Default: Mişari Raşid
  String _selectedTranslation = 'tr.diyanet'; // Default: Diyanet İşleri
  final AudioPlayer _audioPlayer = AudioPlayer();
  static const _widgetChannel = MethodChannel('com.ezanvakti.app/widget');

  bool _isPlaying = false;
  int _currentAyahIndex = -1; // -1 means no ayah playing currently

  // Bookmark / Last Read position
  int? _lastSurahNumber;
  String? _lastSurahName;
  int? _lastAyahNumber;

  FavoriteAyahModel? _pinnedAyah;

  List<SurahModel> get surahList => _surahList;
  SurahModel? get currentSurah => _currentSurah;
  List<AyahModel> get ayahs => _ayahs;
  List<FavoriteAyahModel> get favorites => _favorites;
  FavoriteAyahModel? get pinnedAyah => _pinnedAyah;
  bool get isLoadingSurahs => _isLoadingSurahs;
  bool get isLoadingAyahs => _isLoadingAyahs;
  String get errorMessage => _errorMessage;
  HafizModel get selectedHafiz => _selectedHafiz;
  String get selectedTranslation => _selectedTranslation;
  QuranTranslation get currentTranslation => QuranTranslations.getById(_selectedTranslation);
  bool get isPlaying => _isPlaying;
  int get currentAyahIndex => _currentAyahIndex;

  bool _isBesmelePlaying = false;
  bool get isBesmelePlaying => _isBesmelePlaying;

  int? get lastSurahNumber => _lastSurahNumber;
  String? get lastSurahName => _lastSurahName;
  int? get lastAyahNumber => _lastAyahNumber;

  AyahModel? get currentPlayingAyah {
    if (_currentAyahIndex >= 0 && _currentAyahIndex < _ayahs.length) {
      return _ayahs[_currentAyahIndex];
    }
    return null;
  }

  String get activeTrackTitle {
    if (_isBesmelePlaying) {
      return '${_currentSurah?.nameTr ?? "Sure"}, Besmele';
    } else if (_currentSurah != null && _currentAyahIndex >= 0 && _currentAyahIndex < _ayahs.length) {
      return '${_currentSurah!.nameTr}, ${_ayahs[_currentAyahIndex].numberInSurah}. Ayet';
    } else if (_pinnedAyah != null) {
      return '${_pinnedAyah!.surahName}, ${_pinnedAyah!.ayahNumber}. Ayet';
    } else if (_lastSurahName != null && _lastAyahNumber != null) {
      return '$_lastSurahName, $_lastAyahNumber. Ayet';
    }
    return 'Fatiha Suresi';
  }

  QuranProvider() {
    _init();
  }

  Future<void> _init() async {
    _initAudioListeners();
    await loadSavedTranslation();
    await loadSurahList();
    await loadLastReadPosition();
    await loadFavorites();
    await loadPinnedAyah();
  }

  String? _audioFeedbackMessage;
  String? get audioFeedbackMessage => _audioFeedbackMessage;
  void clearAudioFeedback() {
    _audioFeedbackMessage = null;
  }

  void _initAudioListeners() {
    try {
      _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      _audioPlayer.setReleaseMode(ReleaseMode.stop);
      _audioPlayer.setVolume(1.0);
      _audioPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
            audioMode: AndroidAudioMode.normal,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.defaultToSpeaker,
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('AudioPlayer init error: $e');
    }

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = (state == PlayerState.playing);
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (_isBesmelePlaying) {
        _isBesmelePlaying = false;
        // Besmele tamamlandı, şimdi 1. ayeti okumaya başla
        playAyah(0, isAutoAdvance: true);
      } else if (_currentSurah?.number == 1 && _currentAyahIndex >= 5) {
        // Fatiha'da 6. ayet (001007.mp3) bittiğinde 7. ayet de okunmuş olur, sure biter
        _isPlaying = false;
        _currentAyahIndex = -1;
        notifyListeners();
      } else if (_currentAyahIndex != -1 && _currentAyahIndex + 1 < _ayahs.length) {
        playAyah(_currentAyahIndex + 1, isAutoAdvance: true);
      } else {
        _isPlaying = false;
        _currentAyahIndex = -1;
        notifyListeners();
      }
    });
  }

  Future<void> loadSurahList() async {
    _isLoadingSurahs = true;
    notifyListeners();
    try {
      _surahList = await QuranService.getSurahList();
    } catch (e) {
      _errorMessage = 'Sureler yüklenemedi';
    } finally {
      _isLoadingSurahs = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedTranslation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('selected_quran_translation');
      if (saved != null && saved.isNotEmpty) {
        _selectedTranslation = saved;
      }
    } catch (_) {}
  }

  Future<void> selectTranslation(String translationId) async {
    if (_selectedTranslation == translationId) return;
    _selectedTranslation = translationId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_quran_translation', translationId);
    final trans = QuranTranslations.getById(translationId);
    await prefs.setString('selected_translation_lang', trans.languageCode);
    await _updateNativeQuranWidget();
    notifyListeners();

    // If a surah is currently loaded, reload it with the newly chosen translation
    if (_currentSurah != null) {
      await loadSurah(_currentSurah!.number, autoPlayAyahIndex: _isPlaying ? _currentAyahIndex : null);
    }
  }

  Future<void> loadSurah(int surahNumber, {int? autoPlayAyahIndex}) async {
    _isLoadingAyahs = true;
    _errorMessage = '';
    _ayahs = [];
    _currentSurah = _surahList.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => SurahModel(
        number: surahNumber,
        nameAr: '',
        nameTr: 'Sure $surahNumber',
        englishNameTranslation: '',
        numberOfAyahs: 0,
        revelationType: 'Meccan',
      ),
    );
    notifyListeners();

    try {
      _ayahs = await QuranService.getSurahAyahs(surahNumber, translationId: _selectedTranslation);
      if (autoPlayAyahIndex != null && autoPlayAyahIndex < _ayahs.length) {
        await playAyah(autoPlayAyahIndex);
      }
    } catch (e) {
      _errorMessage = 'Ayetler yüklenirken hata oluştu: İnternet bağlantınızı kontrol ediniz.';
    } finally {
      _isLoadingAyahs = false;
      notifyListeners();
    }
  }

  void selectHafiz(HafizModel hafiz) async {
    _selectedHafiz = hafiz;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_hafiz_id', hafiz.id);
    notifyListeners();

    // If audio was playing, restart current ayah with new Hafiz audio
    if (_isPlaying && _currentAyahIndex != -1) {
      await playAyah(_currentAyahIndex, isAutoAdvance: true);
    }
  }

  // Çevrimdışı hazır MP3 sesleri bulunan sureler (Namaz sureleri & İnşirah)
  static const Set<int> _offlineAudioSurahs = {
    1, 94, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114
  };

  /// Stops native Android widget background audio service if running
  Future<void> stopWidgetAudioService() async {
    try {
      await _widgetChannel.invokeMethod('stopQuranAudioService');
    } catch (e) {
      debugPrint('Error stopping widget audio service: $e');
    }
  }

  Future<void> playAyah(int index, {bool isAutoAdvance = false}) async {
    if (index < 0 || index >= _ayahs.length || _currentSurah == null) return;

    // Widget ses servisi çalıyorsa durdur (seslerin üst üste binmesini önler)
    await stopWidgetAudioService();

    final surahNum = _currentSurah!.number;

    // 1. ayet dinleme butonuna tıklandığında (veya baştan başlatıldığında) ve Tevbe (9) değilse,
    // ÖNCE BESMELE SESİ ÇALSIN, ardından sure okunmaya başlasın!
    if (index == 0 && !isAutoAdvance && surahNum != 9) {
      _isBesmelePlaying = true;
      _currentAyahIndex = 0;
      try {
        bool played = false;
        if (_selectedHafiz.id == 'alafasy' || _offlineAudioSurahs.contains(surahNum)) {
          await _audioPlayer.play(AssetSource('audio/001001.mp3'));
          played = true;
        } else {
          try {
            final bismillahUrl = 'https://www.everyayah.com/data/${_selectedHafiz.serverPath}/001001.mp3';
            await _audioPlayer.play(UrlSource(bismillahUrl));
            played = true;
          } catch (_) {
            await _audioPlayer.play(AssetSource('audio/001001.mp3'));
            played = true;
          }
        }
        if (played) {
          _isPlaying = true;
          _errorMessage = '';
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('Besmele çalma hatası: $e');
        _isBesmelePlaying = false;
      }
    }

    _isBesmelePlaying = false;
    _currentAyahIndex = index;
    final ayah = _ayahs[index];

    // Ses dosyası numarası hesabı:
    // Fatiha (1) için 1. ayet "Elhamdülillahi Rabbil Alemin" olduğundan:
    // index 0 -> 001002.mp3 (Elhamdülillah)
    // index 1 -> 001003.mp3 (Errahmanirrahim)
    // index 2 -> 001004.mp3 (Maliki yevmiddin)
    // index 3 -> 001005.mp3 (Iyyake na'budu)
    // index 4 -> 001006.mp3 (Ihdinas-sirat)
    // index 5, 6 -> 001007.mp3 (Siratallezine...)
    int audioAyahNum = ayah.numberInSurah;
    if (surahNum == 1) {
      if (index == 0) {
        audioAyahNum = 2;
      } else if (index == 1) {
        audioAyahNum = 3;
      } else if (index == 2) {
        audioAyahNum = 4;
      } else if (index == 3) {
        audioAyahNum = 5;
      } else if (index == 4) {
        audioAyahNum = 6;
      } else {
        audioAyahNum = 7;
      }
    }

    final sStr = surahNum.toString().padLeft(3, '0');
    final aStr = audioAyahNum.toString().padLeft(3, '0');

    try {
      bool played = false;
      // 1. Çevrimdışı hazır MP3 kontrolü (Namaz sureleri & İnşirah)
      if (_offlineAudioSurahs.contains(surahNum) && _selectedHafiz.id == 'alafasy') {
        await _audioPlayer.play(AssetSource('audio/$sStr$aStr.mp3'));
        played = true;
      } else {
        // 2. Çevrimiçi sunucudan akıt
        try {
          final audioUrl = ayah.getAudioUrl(surahNum, _selectedHafiz.serverPath);
          await _audioPlayer.play(UrlSource(audioUrl));
          played = true;
        } catch (streamError) {
          debugPrint('Online stream failed for ${_selectedHafiz.nameTr}: $streamError');
          if (_offlineAudioSurahs.contains(surahNum)) {
            await _audioPlayer.play(AssetSource('audio/$sStr$aStr.mp3'));
            _audioFeedbackMessage = '${_selectedHafiz.nameTr} sesine bağlanılamadı, hazır ses çalınıyor.';
            played = true;
          } else {
            rethrow;
          }
        }
      }

      if (played) {
        _isPlaying = true;
        _errorMessage = '';
      }
    } catch (e) {
      debugPrint('playAyah audio error: $e');
      _isPlaying = false;
      _errorMessage = 'Ses yüklenemedi. Bu sure için internet bağlantınızı kontrol ediniz.';
      _audioFeedbackMessage = 'Ses yüklenemedi. İnternet bağlantınızı kontrol ediniz.';
    }

    // Save bookmark
    await saveLastReadPosition(
      surahNumber: _currentSurah!.number,
      surahName: _currentSurah!.nameTr,
      ayahNumber: ayah.numberInSurah,
    );

    // Sync with native Android widget
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_audio_surah', _currentSurah!.nameTr);
      await prefs.setInt('current_audio_ayah', ayah.numberInSurah);
      await prefs.setInt('current_audio_surah_num', _currentSurah!.number);
      await prefs.setBool('is_audio_playing', _isPlaying);
      await _updateNativeQuranWidget();
    } catch (_) {}

    notifyListeners();
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_audio_playing', false);
      await _updateNativeQuranWidget();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> resumeAudio() async {
    await stopWidgetAudioService();
    if (_currentAyahIndex != -1 && _currentAyahIndex < _ayahs.length) {
      try {
        await _audioPlayer.resume();
        _isPlaying = true;
        notifyListeners();
      } catch (_) {
        await playAyah(_currentAyahIndex);
      }
    } else if (_ayahs.isNotEmpty) {
      await playAyah(0);
    }
  }

  Future<void> stopAudio() async {
    _isBesmelePlaying = false;
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    _isPlaying = false;
    _currentAyahIndex = -1;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_audio_playing', false);
      await _updateNativeQuranWidget();
    } catch (_) {}
    notifyListeners();
  }

  // Save last read position to persistent storage
  Future<void> saveLastReadPosition({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
  }) async {
    _lastSurahNumber = surahNumber;
    _lastSurahName = surahName;
    _lastAyahNumber = ayahNumber;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_surah_number', surahNumber);
    await prefs.setString('last_surah_name', surahName);
    await prefs.setInt('last_ayah_number', ayahNumber);
    notifyListeners();
  }

  Future<void> loadLastReadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSurahNumber = prefs.getInt('last_surah_number');
    _lastSurahName = prefs.getString('last_surah_name');
    _lastAyahNumber = prefs.getInt('last_ayah_number');

    final savedHafizId = prefs.getString('selected_hafiz_id');
    if (savedHafizId != null) {
      _selectedHafiz = HafizList.getById(savedHafizId);
    }
    notifyListeners();
  }

  // Favorite Ayahs Methods
  bool isAyahFavorite(int surahNumber, int ayahNumber) {
    return _favorites.any(
      (f) => f.surahNumber == surahNumber && f.ayahNumber == ayahNumber,
    );
  }

  Future<bool> toggleFavorite({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required String textAr,
    required String textTr,
  }) async {
    final existingIndex = _favorites.indexWhere(
      (f) => f.surahNumber == surahNumber && f.ayahNumber == ayahNumber,
    );

    bool added = false;
    if (existingIndex >= 0) {
      _favorites.removeAt(existingIndex);
      added = false;
    } else {
      _favorites.insert(
        0,
        FavoriteAyahModel(
          surahNumber: surahNumber,
          surahName: surahName,
          ayahNumber: ayahNumber,
          textAr: textAr,
          textTr: textTr,
        ),
      );
      added = true;
    }

    notifyListeners();
    await _saveFavorites();
    return added;
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('favorite_ayahs') ?? [];
      _favorites = list.map((jsonStr) => FavoriteAyahModel.fromJson(jsonStr)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _favorites.map((f) => f.toJson()).toList();
      await prefs.setStringList('favorite_ayahs', list);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Pinned Ayah Methods
  bool isAyahPinned(int surahNumber, int ayahNumber) {
    if (_pinnedAyah == null) return false;
    return _pinnedAyah!.surahNumber == surahNumber &&
        _pinnedAyah!.ayahNumber == ayahNumber;
  }

  Future<void> pinAyah(FavoriteAyahModel ayah) async {
    _pinnedAyah = ayah;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pinned_ayah', ayah.toJson());
      await prefs.setString('pinned_arabic', ayah.textAr);
      await prefs.setString('pinned_turkish', ayah.textTr);
      await prefs.setString('pinned_surah', ayah.surahName);
      await prefs.setInt('pinned_ayah_num', ayah.ayahNumber);
      _updateNativePinnedWidget();
    } catch (e) {
      debugPrint('Error saving pinned ayah: $e');
    }
  }

  Future<void> unpinAyah() async {
    _pinnedAyah = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pinned_ayah');
      await prefs.remove('pinned_arabic');
      await prefs.remove('pinned_turkish');
      await prefs.remove('pinned_surah');
      await prefs.remove('pinned_ayah_num');
      _updateNativePinnedWidget();
    } catch (e) {
      debugPrint('Error removing pinned ayah: $e');
    }
  }

  Future<void> loadPinnedAyah() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('pinned_ayah');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        _pinnedAyah = FavoriteAyahModel.fromJson(jsonStr);
      } else {
        // Default pinned ayah: İnşirah Suresi 5. Ayet
        _pinnedAyah = FavoriteAyahModel(
          surahNumber: 94,
          surahName: 'İnşirah',
          ayahNumber: 5,
          textAr: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
          textTr: 'Şüphesiz her güçlükle beraber bir kolaylık vardır.',
        );
        // Persist default for native widget
        await prefs.setString('pinned_arabic', _pinnedAyah!.textAr);
        await prefs.setString('pinned_turkish', _pinnedAyah!.textTr);
        await prefs.setString('pinned_surah', _pinnedAyah!.surahName);
        await prefs.setInt('pinned_ayah_num', _pinnedAyah!.ayahNumber);
      }
      _updateNativePinnedWidget();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pinned ayah: $e');
    }
  }

  Future<void> _updateNativePinnedWidget() async {
    try {
      await _widgetChannel.invokeMethod('updatePinnedAyahWidget');
    } catch (e) {
      debugPrint('Error updating native pinned widget: $e');
    }
  }

  Future<void> _updateNativeQuranWidget() async {
    try {
      await _widgetChannel.invokeMethod('updateQuranWidget');
    } catch (e) {
      debugPrint('Error updating native quran widget: $e');
    }
  }

  // Home Screen Quick Audio Controls
  Future<void> quickTogglePlayFromHome() async {
    if (_isPlaying) {
      await pauseAudio();
      return;
    }

    if (_currentAyahIndex != -1 && _ayahs.isNotEmpty) {
      await resumeAudio();
      return;
    }

    if (_pinnedAyah != null) {
      await playPinnedAyahAudio();
      return;
    }

    if (_lastSurahNumber != null) {
      final targetIndex = (_lastAyahNumber != null && _lastAyahNumber! > 0)
          ? (_lastAyahNumber! - 1)
          : 0;
      await loadSurah(_lastSurahNumber!, autoPlayAyahIndex: targetIndex);
      return;
    }

    // Default to Fatiha 1:1
    await loadSurah(1, autoPlayAyahIndex: 0);
  }

  Future<void> playPinnedAyahAudio() async {
    if (_pinnedAyah == null) return;
    final pin = _pinnedAyah!;
    if (_currentSurah?.number != pin.surahNumber || _ayahs.isEmpty) {
      await loadSurah(pin.surahNumber);
    }
    final targetIndex =
        _ayahs.indexWhere((a) => a.numberInSurah == pin.ayahNumber);
    if (targetIndex != -1) {
      await playAyah(targetIndex);
    } else if (_ayahs.isNotEmpty) {
      await playAyah(0);
    }
  }

  Future<void> playNextAyah() async {
    if (_currentSurah == null || _ayahs.isEmpty) {
      await quickTogglePlayFromHome();
      return;
    }
    if (_currentAyahIndex + 1 < _ayahs.length) {
      await playAyah(_currentAyahIndex + 1);
    }
  }

  Future<void> playPreviousAyah() async {
    if (_currentSurah == null || _ayahs.isEmpty) return;
    if (_currentAyahIndex > 0) {
      await playAyah(_currentAyahIndex - 1);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

