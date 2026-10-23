import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/prayer_times_model.dart';

class PrayerService {
  static const String _cachedTimesKey = 'cached_prayer_times_json';
  static const String _cachedLocationKey = 'cached_prayer_times_location';

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
        await _saveCache(response.body, locationName);
        return PrayerTimesModel.fromJson(data, locationName);
      } else {
        throw Exception('Server Error ${response.statusCode}');
      }
    } catch (e) {
      final cached = await loadCache();
      if (cached != null) return cached;
      return getFallbackTimes(locationName);
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
        await _saveCache(response.body, '$city, $country');
        return PrayerTimesModel.fromJson(data, '$city, $country');
      } else {
        throw Exception('Server Error ${response.statusCode}');
      }
    } catch (e) {
      final cached = await loadCache();
      if (cached != null) return cached;
      return getFallbackTimes('$city, $country');
    }
  }

  static Future<void> _saveCache(String body, String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedTimesKey, body);
      await prefs.setString(_cachedLocationKey, location);
    } catch (_) {}
  }

  static Future<PrayerTimesModel?> loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final body = prefs.getString(_cachedTimesKey);
      final location = prefs.getString(_cachedLocationKey);
      if (body != null && location != null) {
        final data = json.decode(body);
        return PrayerTimesModel.fromJson(data, location);
      }
    } catch (_) {}
    return null;
  }

  static PrayerTimesModel getFallbackTimes(String location) {
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
