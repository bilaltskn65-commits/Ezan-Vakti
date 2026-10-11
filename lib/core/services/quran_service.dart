import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/surah_model.dart';
import '../../models/ayah_model.dart';

class QuranService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  // Fetch list of all 114 Surahs
  static Future<List<SurahModel>> getSurahList() async {
    final response = await http.get(Uri.parse('$baseUrl/surah'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['data'];
      return list.map((json) => SurahModel.fromJson(json)).toList();
    } else {
      throw Exception('Sure listesi yüklenemedi');
    }
  }

  // Fetch Ayahs for a specific surah (Arabic Uthmani script + Turkish Diyanet translation)
  static Future<List<AyahModel>> getSurahAyahs(int surahNumber) async {
    final response = await http.get(
      Uri.parse('$baseUrl/surah/$surahNumber/editions/quran-uthmani,tr.diyanet'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List editions = data['data'];

      final Map<String, dynamic> arabicEdition = editions[0];
      final Map<String, dynamic> turkishEdition = editions.length > 1 ? editions[1] : editions[0];

      final List arabicAyahs = arabicEdition['ayahs'];
      final List turkishAyahs = turkishEdition['ayahs'];

      List<AyahModel> result = [];
      for (int i = 0; i < arabicAyahs.length; i++) {
        final ar = arabicAyahs[i];
        final tr = i < turkishAyahs.length ? turkishAyahs[i] : null;
        result.add(AyahModel.fromJson(ar, tr));
      }
      return result;
    } else {
      throw Exception('Ayetler yüklenemedi');
    }
  }
}

