import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/surah_model.dart';
import '../../models/ayah_model.dart';
import '../constants/quran_surahs_data.dart';
import '../constants/bundled_ayahs_data.dart';

class QuranTranslationLanguage {
  final String code;
  final String name;
  final String flag;

  const QuranTranslationLanguage({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class QuranTranslation {
  final String id;
  final String name;
  final String author;
  final String description;
  final String languageCode;

  const QuranTranslation({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    required this.languageCode,
  });
}

class QuranTranslations {
  static const List<QuranTranslationLanguage> languages = [
    QuranTranslationLanguage(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
    QuranTranslationLanguage(code: 'en', name: 'English', flag: '🇬🇧'),
    QuranTranslationLanguage(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
    QuranTranslationLanguage(code: 'fr', name: 'Français', flag: '🇫🇷'),
    QuranTranslationLanguage(code: 'ru', name: 'Русский', flag: '🇷🇺'),
    QuranTranslationLanguage(code: 'az', name: 'Azərbaycan', flag: '🇦🇿'),
    QuranTranslationLanguage(code: 'bs', name: 'Bosanski', flag: '🇧🇦'),
    QuranTranslationLanguage(code: 'ar', name: 'Tefsir', flag: '📖'),
  ];

  static const List<QuranTranslation> all = [
    // --- TÜRKÇE ---
    QuranTranslation(
      id: 'tr.diyanet',
      name: 'Diyanet İşleri',
      author: 'Diyanet İşleri Başkanlığı',
      description: 'Resmi Türkçe meal (Dahili & Çevrimdışı hazır)',
      languageCode: 'tr',
    ),
    QuranTranslation(
      id: 'tr.yazir',
      name: 'Elmalılı Hamdi Yazır',
      author: 'Elmalılı M. Hamdi Yazır',
      description: 'Klasik başyapıt: Hak Dini Kur\'an Dili',
      languageCode: 'tr',
    ),
    QuranTranslation(
      id: 'tr.vakfi',
      name: 'Diyanet Vakfı',
      author: 'Türkiye Diyanet Vakfı (TDV)',
      description: 'Heyet tarafından hazırlanan güvenilir meal',
      languageCode: 'tr',
    ),

    // --- ENGLISH ---
    QuranTranslation(
      id: 'en.sahih',
      name: 'Saheeh International',
      author: 'Saheeh International',
      description: 'The most popular modern & clear English translation',
      languageCode: 'en',
    ),
    QuranTranslation(
      id: 'en.yusufali',
      name: 'Abdullah Yusuf Ali',
      author: 'Abdullah Yusuf Ali',
      description: 'Renowned literary classical translation with explanatory notes',
      languageCode: 'en',
    ),
    QuranTranslation(
      id: 'en.pickthall',
      name: 'Marmaduke Pickthall',
      author: 'M. Marmaduke Pickthall',
      description: 'The Meaning of the Glorious Koran',
      languageCode: 'en',
    ),
    QuranTranslation(
      id: 'en.asad',
      name: 'Muhammad Asad',
      author: 'Muhammad Asad (Leopold Weiss)',
      description: 'The Message of the Qur\'an - deep intellectual translation',
      languageCode: 'en',
    ),

    // --- DEUTSCH ---
    QuranTranslation(
      id: 'de.bubenheim',
      name: 'Bubenheim & Elyas',
      author: 'A. S. F. Bubenheim und N. Elyas',
      description: 'Weit verbreitete und verlässliche deutsche Übersetzung',
      languageCode: 'de',
    ),
    QuranTranslation(
      id: 'de.aburida',
      name: 'Abu Rida',
      author: 'Abu Rida Muhammad ibn Ahmad',
      description: 'Deutsche Übersetzung des Edlen Qur\'an',
      languageCode: 'de',
    ),

    // --- FRANÇAIS ---
    QuranTranslation(
      id: 'fr.hamidullah',
      name: 'Muhammad Hamidullah',
      author: 'Dr. Muhammad Hamidullah',
      description: 'Traduction française la plus célèbre et académique',
      languageCode: 'fr',
    ),

    // --- РУССКИЙ ---
    QuranTranslation(
      id: 'ru.kuliev',
      name: 'Эльмир Кулиев',
      author: 'Эльмир Кулиев',
      description: 'Наиболее авторитетный современный русский перевод',
      languageCode: 'ru',
    ),
    QuranTranslation(
      id: 'ru.osmanov',
      name: 'Магомед-Нури Османов',
      author: 'М. Н. Османов',
      description: 'Академический перевод смыслов Корана',
      languageCode: 'ru',
    ),

    // --- AZƏRBAYCAN ---
    QuranTranslation(
      id: 'az.mammadaliyev',
      name: 'Məmmədəliyev & Bünyadov',
      author: 'V. Məmmədəliyev və Z. Bünyadov',
      description: 'Ən məşhur və etibarlı Azərbaycan tərcüməsi',
      languageCode: 'az',
    ),
    QuranTranslation(
      id: 'az.musayev',
      name: 'Əlixan Musayev',
      author: 'Əlixan Musayev',
      description: 'Qurani-Kərimin Azərbaycan dilinə tərcüməsi',
      languageCode: 'az',
    ),

    // --- BOSANSKI ---
    QuranTranslation(
      id: 'bs.korkut',
      name: 'Besim Korkut',
      author: 'Besim Korkut',
      description: 'Najpoznatiji i najcjenjeniji bosanski prevod Kur\'ana',
      languageCode: 'bs',
    ),

    // --- TEFSİR (ARAPÇA AÇIKLAMALI) ---
    QuranTranslation(
      id: 'ar.muyassar',
      name: 'Tefsîr-ul Muyesser',
      author: 'تفسير الميسر (Nuhbe min Ulema)',
      description: 'Açıklamalı ve kolay anlaşılır Arapça Kuran tefsiri',
      languageCode: 'ar',
    ),
  ];

  static List<QuranTranslation> getByLanguage(String langCode) {
    return all.where((t) => t.languageCode == langCode).toList();
  }

  static QuranTranslation getById(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => all.first);
  }
}

class QuranService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  // 114 Sure listesi yerel sabit veri tabanından 0ms'de anında döndürülür (İnternetsiz de kesinlikle çalışır)
  static Future<List<SurahModel>> getSurahList() async {
    return kAllSurahs;
  }

  // Sure ayetlerini getir (Arapça Uthmani + Seçili Türkçe Meal)
  // 1. Önbellekte varsa anında döndür
  // 2. Diyanet seçiliyse dahili assets paketinden oku (0ms internetsiz anında yüklenir)
  // 3. Ağdan seçili meal ile çekip önbelleğe al
  static Future<List<AyahModel>> getSurahAyahs(
    int surahNumber, {
    String translationId = 'tr.diyanet',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_surah_ayahs_${translationId}_$surahNumber';
    final cachedJson = prefs.getString(cacheKey);

    // Fâtiha (1) için eski besmeleli önbellek varsa temizle
    if (surahNumber == 1 &&
        cachedJson != null &&
        (cachedJson.contains('بِسْمِ ٱللَّهِ') ||
            cachedJson.contains('Rahman ve Rahim') ||
            cachedJson.contains('Rahmân ve Rahîm'))) {
      await prefs.remove(cacheKey);
    } else if (cachedJson != null) {
      return parseAyahsFromJson(cachedJson);
    }

    // 2. Diyanet seçiliyse doğrudan dahili asset dosyasından anında yükle (0ms, %100 çevrimdışı)
    if (translationId == 'tr.diyanet') {
      try {
        final assetJson = await rootBundle.loadString('assets/surahs/$surahNumber.json');
        if (assetJson.isNotEmpty) {
          return parseAyahsFromJson(assetJson);
        }
      } catch (_) {
        // Asset yüklenemezse fallback'e geç
      }

      // Çevrimdışı hazır veri paketinde varsa anında döndür
      if (kBundledSurahsJson.containsKey(surahNumber)) {
        final jsonStr = kBundledSurahsJson[surahNumber]!;
        await prefs.setString(cacheKey, jsonStr);
        return parseAyahsFromJson(jsonStr);
      }
    }

    // 3. Ağdan seçilen mealle getir ve gelecekte internetsiz kullanım için önbelleğe al
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/surah/$surahNumber/editions/quran-uthmani,$translationId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);
        return parseAyahsFromJson(response.body);
      }
    } catch (_) {
      // Ağ hatasında eğer Diyanet dahili asset'i varsa kullanıcıyı boş bırakmamak için son çare olarak onu gösterelim
      try {
        final assetJson = await rootBundle.loadString('assets/surahs/$surahNumber.json');
        if (assetJson.isNotEmpty) {
          return parseAyahsFromJson(assetJson);
        }
      } catch (_) {}
      throw Exception('Ayetler yüklenemedi. Lütfen internet bağlantınızı kontrol ediniz.');
    }

    throw Exception('Ayetler yüklenemedi. Lütfen internet bağlantınızı kontrol ediniz.');
  }

  static List<AyahModel> parseAyahsFromJson(String jsonString) {
    final data = json.decode(jsonString);
    final List editions = data['data'];

    final Map<String, dynamic> arabicEdition = editions[0];
    final Map<String, dynamic> turkishEdition =
        editions.length > 1 ? editions[1] : editions[0];

    final int surahNumber = arabicEdition['number'] ?? 1;

    final List arabicAyahs = arabicEdition['ayahs'];
    final List turkishAyahs = turkishEdition['ayahs'];

    // Fâtiha (1) özel düzenlemesi:
    // 1. ayet mutlaka "Elhamdülillahi Rabbil Alemin" olmalıdır (Besmele serlevha/başlıkta yer alır).
    // Gelen veride 1. ayet Besmele ise, onu ayet listesinden çıkarıp 1: Elhamdülillah'tan başlatıyoruz.
    if (surahNumber == 1 && arabicAyahs.isNotEmpty) {
      final firstText = (arabicAyahs[0]['text'] ?? '').toString().trim();
      const bismillah1 = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
      const bismillah2 = 'بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
      if (firstText.contains(bismillah1) || firstText.contains(bismillah2)) {
        List<AyahModel> fatihaList = [];
        for (int k = 1; k <= 5 && k < arabicAyahs.length; k++) {
          final arMap = Map<String, dynamic>.from(arabicAyahs[k]);
          arMap['numberInSurah'] = k;
          final trMap = k < turkishAyahs.length ? Map<String, dynamic>.from(turkishAyahs[k]) : null;
          if (trMap != null) trMap['numberInSurah'] = k;
          fatihaList.add(AyahModel.fromJson(arMap, trMap));
        }
        fatihaList.add(AyahModel(
          number: 6,
          numberInSurah: 6,
          juz: 1,
          page: 1,
          textAr: 'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ',
          textTr: 'Nimete erdirdiğin kimselerin yoluna;',
        ));
        fatihaList.add(AyahModel(
          number: 7,
          numberInSurah: 7,
          juz: 1,
          page: 1,
          textAr: 'غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ',
          textTr: 'Gazaba uğrayanların ya da sapıtanların yoluna değil.',
        ));
        return fatihaList;
      }
    }

    List<AyahModel> result = [];
    for (int i = 0; i < arabicAyahs.length; i++) {
      final Map<String, dynamic> ar = Map<String, dynamic>.from(arabicAyahs[i]);
      final tr = i < turkishAyahs.length ? turkishAyahs[i] : null;

      // Fâtiha (1) ve Tevbe (9) dışındaki surelerin 1. ayetinin başında
      // API'den veya önbellekten gelen gömülü Besmele varsa temizle
      if (surahNumber > 1 && i == 0) {
        String textAr = (ar['text'] ?? '').toString();
        const bismillah1 = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
        const bismillah2 = 'بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
        if (textAr.startsWith(bismillah1)) {
          textAr = textAr.substring(bismillah1.length).trim();
        } else if (textAr.startsWith(bismillah2)) {
          textAr = textAr.substring(bismillah2.length).trim();
        }
        ar['text'] = textAr;
      }

      result.add(AyahModel.fromJson(ar, tr));
    }
    return result;
  }
}
