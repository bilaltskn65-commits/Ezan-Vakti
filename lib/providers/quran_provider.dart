import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';
import '../models/hafiz_model.dart';
import '../core/services/quran_service.dart';

class QuranProvider extends ChangeNotifier {
  List<SurahModel> _surahList = [];
  SurahModel? _currentSurah;
  List<AyahModel> _ayahs = [];
  bool _isLoadingSurahs = false;
  bool _isLoadingAyahs = false;
  String _errorMessage = '';

  HafizModel _selectedHafiz = HafizList.reciters.first; // Default: Mişari Raşid
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  int _currentAyahIndex = -1; // -1 means no ayah playing currently

  // Bookmark / Last Read position
  int? _lastSurahNumber;
  String? _lastSurahName;
  int? _lastAyahNumber;

  List<SurahModel> get surahList => _surahList;
  SurahModel? get currentSurah => _currentSurah;
  List<AyahModel> get ayahs => _ayahs;
  bool get isLoadingSurahs => _isLoadingSurahs;
  bool get isLoadingAyahs => _isLoadingAyahs;
  String get errorMessage => _errorMessage;
  HafizModel get selectedHafiz => _selectedHafiz;
  bool get isPlaying => _isPlaying;
  int get currentAyahIndex => _currentAyahIndex;

  int? get lastSurahNumber => _lastSurahNumber;
  String? get lastSurahName => _lastSurahName;
  int? get lastAyahNumber => _lastAyahNumber;

  QuranProvider() {
    _init();
  }

  Future<void> _init() async {
    _initAudioListeners();
    await loadSurahList();
    await loadLastReadPosition();
  }

  void _initAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = (state == PlayerState.playing);
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      // Automatically advance to the next verse in the surah!
      if (_currentAyahIndex != -1 && _currentAyahIndex + 1 < _ayahs.length) {
        playAyah(_currentAyahIndex + 1);
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

  Future<void> loadSurah(int surahNumber, {int? autoPlayAyahIndex}) async {
    _isLoadingAyahs = true;
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
      _ayahs = await QuranService.getSurahAyahs(surahNumber);
      if (autoPlayAyahIndex != null && autoPlayAyahIndex < _ayahs.length) {
        await playAyah(autoPlayAyahIndex);
      }
    } catch (e) {
      _errorMessage = 'Ayetler yüklenirken hata oluştu';
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
      await playAyah(_currentAyahIndex);
    }
  }

  Future<void> playAyah(int index) async {
    if (index < 0 || index >= _ayahs.length || _currentSurah == null) return;

    _currentAyahIndex = index;
    final ayah = _ayahs[index];
    final audioUrl = ayah.getAudioUrl(_currentSurah!.number, _selectedHafiz.serverPath);

    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(audioUrl));
    _isPlaying = true;

    // Save bookmark
    await saveLastReadPosition(
      surahNumber: _currentSurah!.number,
      surahName: _currentSurah!.nameTr,
      ayahNumber: ayah.numberInSurah,
    );

    notifyListeners();
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resumeAudio() async {
    if (_currentAyahIndex != -1) {
      await _audioPlayer.resume();
      _isPlaying = true;
      notifyListeners();
    } else if (_ayahs.isNotEmpty) {
      await playAyah(0);
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentAyahIndex = -1;
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

