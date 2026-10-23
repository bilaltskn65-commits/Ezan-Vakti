import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_vakti/models/prayer_times_model.dart';
import 'package:ezan_vakti/core/services/prayer_service.dart';

void main() {
  group('PrayerTimesModel Tests', () {
    final mockJson = {
      'data': {
        'timings': {
          'Fajr': '05:42',
          'Sunrise': '07:05',
          'Dhuhr': '12:58',
          'Asr': '16:04',
          'Maghrib': '18:41',
          'Isha': '19:58',
        },
        'date': {
          'readable': '23 Oct 2026',
        },
        'meta': {
          'timezone': 'Europe/Istanbul',
        }
      }
    };

    test('PrayerTimesModel.fromJson correctly parses Aladhan API response', () {
      final model = PrayerTimesModel.fromJson(mockJson, 'İstanbul, Türkiye');

      expect(model.fajr, '05:42');
      expect(model.sunrise, '07:05');
      expect(model.dhuhr, '12:58');
      expect(model.asr, '16:04');
      expect(model.maghrib, '18:41');
      expect(model.isha, '19:58');
      expect(model.date, '23 Oct 2026');
      expect(model.timezone, 'Europe/Istanbul');
      expect(model.locationName, 'İstanbul, Türkiye');
    });

    test('asList map returns exactly 6 prayer times in correct Turkish order', () {
      final model = PrayerTimesModel.fromJson(mockJson, 'Ankara');
      final list = model.asList;

      expect(list.length, 6);
      expect(list.keys.toList(), ['İmsak', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı']);
      expect(list['İmsak'], '05:42');
      expect(list['Güneş'], '07:05');
      expect(list['Öğle'], '12:58');
      expect(list['İkindi'], '16:04');
      expect(list['Akşam'], '18:41');
      expect(list['Yatsı'], '19:58');
    });

    test('getPrayerDateTime parses standard and formatted time strings', () {
      final model = PrayerTimesModel.fromJson(mockJson, 'İzmir');

      final dt1 = model.getPrayerDateTime('12:58');
      expect(dt1, isNotNull);
      expect(dt1!.hour, 12);
      expect(dt1.minute, 58);

      // Suffix with timezone like "12:58 (+03)"
      final dt2 = model.getPrayerDateTime('18:41 (+03)');
      expect(dt2, isNotNull);
      expect(dt2!.hour, 18);
      expect(dt2.minute, 41);

      // Malformed string
      final dt3 = model.getPrayerDateTime('invalid:time');
      expect(dt3, isNull);
    });

    test('getNextPrayer returns non-null prayer payload with valid progress', () {
      final model = PrayerTimesModel.fromJson(mockJson, 'Bursa');
      final nextInfo = model.getNextPrayer();

      expect(nextInfo, contains('name'));
      expect(nextInfo, contains('time'));
      expect(nextInfo, contains('currentName'));
      expect(nextInfo, contains('currentTime'));
      expect(nextInfo, contains('remaining'));
      expect(nextInfo, contains('progress'));

      final progress = nextInfo['progress'] as double;
      expect(progress >= 0.0 && progress <= 1.0, isTrue);

      final remaining = nextInfo['remaining'] as Duration;
      expect(remaining.isNegative, isFalse);
    });

    test('PrayerService.getFallbackTimes generates consistent offline data', () {
      final fallback = PrayerService.getFallbackTimes('Van, Türkiye');

      expect(fallback.locationName, 'Van, Türkiye');
      expect(fallback.fajr.isNotEmpty, isTrue);
      expect(fallback.dhuhr.isNotEmpty, isTrue);
      expect(fallback.maghrib.isNotEmpty, isTrue);
      expect(fallback.asList.length, 6);
    });
  });
}
