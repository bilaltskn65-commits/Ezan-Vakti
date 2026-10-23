import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';
import '../core/services/prayer_service.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';

class PrayerProvider extends ChangeNotifier {
  static const MethodChannel _widgetChannel = MethodChannel('com.ezanvakti.app/widget');

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
    // 1. Önce hafızadaki veya varsayılan vakitleri anında yükle (ekran 0 ms'de açılsın)
    try {
      final cached = await PrayerService.loadCache();
      if (cached != null) {
        _prayerTimes = cached;
        _locationName = cached.locationName;
      } else {
        _prayerTimes = PrayerService.getFallbackTimes(_locationName);
      }
    } catch (_) {
      _prayerTimes = PrayerService.getFallbackTimes(_locationName);
    }
    _isLoading = false;
    notifyListeners();

    // 2. Ardından güncel vakitleri ve konumu çek
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
      _checkApproachingPrayerNotification();
      notifyListeners();
    });
  }

  String? _lastNotifiedPrayer;
  DateTime? _lastNotifiedDate;
  String? _lastActivePrayer;

  void _checkApproachingPrayerNotification() {
    if (_prayerTimes == null) return;
    final nextPrayerInfo = _prayerTimes!.getNextPrayer();
    final remaining = nextPrayerInfo['remaining'] as Duration?;
    final nextPrayerName = nextPrayerInfo['name'] as String?;
    final nextTimeStr = nextPrayerInfo['time'] as String?;
    final nextDateTime = nextPrayerInfo['dateTime'] as DateTime?;
    final currentPrayerName = nextPrayerInfo['currentName'] as String?;
    final currentTimeStr = nextPrayerInfo['currentTime'] as String?;

    if (remaining == null || nextPrayerName == null || nextTimeStr == null || nextDateTime == null) {
      return;
    }

    final now = DateTime.now();

    // 1. Namaz vakti geçişi kontrolü: Bir vakit bittiğinde ve yeni vakit girdiğinde
    if (currentPrayerName != null && currentPrayerName.isNotEmpty) {
      if (_lastActivePrayer == null) {
        // Uygulama ilk açıldığında o anki aktif vakti kaydet (geçmiş vakit için aniden ezan çalmasın)
        _lastActivePrayer = currentPrayerName;
      } else if (_lastActivePrayer != currentPrayerName) {
        // VAKİT DEĞİŞTİ! (Örn: İkindi bitti, Akşam vakti girdi)
        final enteredPrayer = currentPrayerName;
        _lastActivePrayer = currentPrayerName;
        _lastNotifiedPrayer = null;

        // Biten vaktin geri sayım bildirimini temizle
        final prayerId = NotificationService.getPrayerNotificationId(enteredPrayer);
        NotificationService.cancelCountdownNotification(prayerId: prayerId);

        // Canlı açık uygulamada vakit giriş ezan bildirimini fırlat ("Allahu Ekber Allahu Ekber")
        NotificationService.showPrayerEntryNotification(
          prayerName: enteredPrayer,
          timeStr: currentTimeStr ?? '',
          prayerId: prayerId + 10,
        );
      }
    }

    // 2. Sıradaki vakte 45 dakika kala kilit ekranında canlı geri sayan sabit sayacı göster
    if (remaining.inSeconds <= 45 * 60 && remaining.inSeconds > 0) {
      if (_lastNotifiedPrayer != nextPrayerName ||
          _lastNotifiedDate == null ||
          _lastNotifiedDate!.day != now.day) {
        _lastNotifiedPrayer = nextPrayerName;
        _lastNotifiedDate = now;
        NotificationService.showApproachingPrayerCountdown(
          prayerName: nextPrayerName,
          timeStr: nextTimeStr,
          prayerDateTime: nextDateTime,
          prayerId: NotificationService.getPrayerNotificationId(nextPrayerName),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchPrayerTimesWithAutoLocation() async {
    if (_prayerTimes == null) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = '';

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
    } catch (e) {
      _errorMessage = 'Namaz vakitleri alınamadı: $e';
      _prayerTimes ??= PrayerService.getFallbackTimes(_locationName);
    } finally {
      if (_prayerTimes != null) {
        try {
          await NotificationService.schedulePrayerNotifications(_prayerTimes!);
          await _updateNativeWidget();
        } catch (_) {}
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPrayerTimesForCity(String city, String country) async {
    if (_prayerTimes == null) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = '';

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
    } catch (e) {
      _errorMessage = 'Seçilen şehir için vakitler alınamadı.';
      _prayerTimes ??= PrayerService.getFallbackTimes('$city, $country');
    } finally {
      if (_prayerTimes != null) {
        try {
          await NotificationService.schedulePrayerNotifications(_prayerTimes!);
          await _updateNativeWidget();
        } catch (_) {}
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateNativeWidget() async {
    try {
      await _widgetChannel.invokeMethod('updateWidget');
    } catch (_) {}
  }
}

