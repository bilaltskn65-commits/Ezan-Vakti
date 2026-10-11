import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';
import '../core/services/prayer_service.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';

class PrayerProvider extends ChangeNotifier {
  PrayerTimesModel? _prayerTimes;
  bool _isLoading = false;
  String _errorMessage = '';
  String _locationName = 'İstanbul, Türkiye';
  bool _isAutoLocation = true;
  Timer? _timer;

  PrayerTimesModel? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get locationName => _locationName;
  bool get isAutoLocation => _isAutoLocation;

  PrayerProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isAutoLocation = prefs.getBool('is_auto_location') ?? true;
    final savedCity = prefs.getString('saved_city');

    if (!_isAutoLocation && savedCity != null && savedCity.isNotEmpty) {
      await fetchPrayerTimesForCity(savedCity, 'Türkiye');
    } else {
      await fetchPrayerTimesWithAutoLocation();
    }

    // Start timer to update countdown UI every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchPrayerTimesWithAutoLocation() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final cityName = await LocationService.getCityFromCoordinates(
          position.latitude,
          position.longitude,
        );
        _locationName = cityName;
        _isAutoLocation = true;

        _prayerTimes = await PrayerService.fetchPrayerTimesByCoordinates(
          lat: position.latitude,
          lng: position.longitude,
          locationName: _locationName,
        );
      } else {
        // Fallback to default city if GPS permission denied or service disabled
        _locationName = 'İstanbul, Türkiye';
        _prayerTimes = await PrayerService.fetchPrayerTimesByCity(
          city: 'Istanbul',
          country: 'Turkey',
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_auto_location', true);

      if (_prayerTimes != null) {
        await NotificationService.schedulePrayerNotifications(_prayerTimes!);
      }
    } catch (e) {
      _errorMessage = 'Namaz vakitleri alınamadı: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPrayerTimesForCity(String city, String country) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _locationName = '$city, $country';
      _isAutoLocation = false;
      _prayerTimes = await PrayerService.fetchPrayerTimesByCity(
        city: city,
        country: country,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_auto_location', false);
      await prefs.setString('saved_city', city);

      if (_prayerTimes != null) {
        await NotificationService.schedulePrayerNotifications(_prayerTimes!);
      }
    } catch (e) {
      _errorMessage = 'Seçilen şehir için vakitler alınamadı.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

