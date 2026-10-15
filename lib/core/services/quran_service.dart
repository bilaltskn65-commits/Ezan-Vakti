import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/surah_model.dart';
import '../../models/ayah_model.dart';
import '../constants/quran_surahs_data.dart';
import '../constants/bundled_ayahs_data.dart';

class QuranService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  // 114 Sure listesi yerel sabit veri tabanından 0ms'de anında döndürülür (İnternetsiz de kesinlikle çalışır)
  static Future<List<SurahModel>> getSurahList() async {
    return kAllSurahs;
  }

  // Sure ayetlerini getir (Arapça Uthmani + Türkçe Diyanet Meali)
  // 1. Önce dahili assets paketinden oku (114 surenin tamamı 0ms internetsiz anında yüklenir)
  // 2. Bulunamazsa önbelleğe ve hazır veriye bak
  // 3. Bulunamazsa ağdan çekip önbelleğe al
  static Future<List<AyahModel>> getSurahAyahs(int surahNumber) async {
    // 1. Doğrudan dahili asset dosyasından anında yükle (0ms, %100 çevrimdışı)
    try {
      final assetJson = await rootBundle.loadString('assets/surahs/$surahNumber.json');
      if (assetJson.isNotEmpty) {
        return parseAyahsFromJson(assetJson);
      }
    } catch (_) {
      // Asset yüklenemezse fallback'e geç
    }

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_surah_ayahs_$surahNumber';
    final cachedJson = prefs.getString(cacheKey);

    // 2. Önbellekte varsa anında döndür
    if (cachedJson != null) {
      return parseAyahsFromJson(cachedJson);
    }

    // 3. Çevrimdışı hazır veri paketinde varsa anında döndür
    if (kBundledSurahsJson.containsKey(surahNumber)) {
      final jsonStr = kBundledSurahsJson[surahNumber]!;
      await prefs.setString(cacheKey, jsonStr);
      return parseAyahsFromJson(jsonStr);
    }

    // 4. Ağdan getir ve gelecekte internetsiz kullanım için önbelleğe al
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/surah/$surahNumber/editions/quran-uthmani,tr.diyanet'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);
        return parseAyahsFromJson(response.body);
      }
    } catch (_) {
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
