import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/prayer_times_model.dart';

class PrayerService {
  // Method 13 is Diyanet İşleri Başkanlığı calculation method
  static Future<PrayerTimesModel> fetchPrayerTimesByCoordinates({
    required double lat,
    required double lng,
    required String locationName,
  }) async {
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=13',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimesModel.fromJson(data, locationName);
      } else {
        throw Exception('Server Error ${response.statusCode}');
      }
    } catch (e) {
      // Return fallback data if network fails
      return _getFallbackTimes(locationName);
    }
  }

  static Future<PrayerTimesModel> fetchPrayerTimesByCity({
    required String city,
    required String country,
  }) async {
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=13',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimesModel.fromJson(data, '$city, $country');
      } else {
        throw Exception('Server Error ${response.statusCode}');
      }
    } catch (e) {
      return _getFallbackTimes('$city, $country');
    }
  }

  static PrayerTimesModel _getFallbackTimes(String location) {
    return PrayerTimesModel(
      fajr: '05:30',
      sunrise: '06:55',
      dhuhr: '13:00',
      asr: '16:15',
      maghrib: '18:50',
      isha: '20:10',
      date: '10 Oct 2026',
      timezone: 'Europe/Istanbul',
      locationName: location,
    );
  }
}

