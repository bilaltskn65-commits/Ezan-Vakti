import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_vakti/core/localization/app_translations.dart';

void main() {
  group('AppTranslations Localization Integrity Tests', () {
    const supportedLangs = ['tr', 'en', 'ar'];

    test('All supported languages have prayer names mapped', () {
      for (final lang in supportedLangs) {
        final prayerMap = AppTranslations.prayerNames[lang];
        expect(prayerMap, isNotNull, reason: 'Missing prayer names for $lang');
        expect(prayerMap!.containsKey('İmsak'), isTrue);
        expect(prayerMap.containsKey('Güneş'), isTrue);
        expect(prayerMap.containsKey('Öğle'), isTrue);
        expect(prayerMap.containsKey('İkindi'), isTrue);
        expect(prayerMap.containsKey('Akşam'), isTrue);
        expect(prayerMap.containsKey('Yatsı'), isTrue);
      }
    });

    test('All supported languages have UI strings dictionary', () {
      for (final lang in supportedLangs) {
        final stringMap = AppTranslations.strings[lang];
        expect(stringMap, isNotNull, reason: 'Missing strings for $lang');
        expect(stringMap!.isNotEmpty, isTrue);
      }
    });

    test('Critical navigation keys exist in all language dictionaries', () {
      const criticalKeys = [
        'nav_prayers',
        'nav_quran',
        'nav_qibla',
        'nav_asma',
        'nav_settings',
        'app_title',
      ];

      for (final lang in supportedLangs) {
        final stringMap = AppTranslations.strings[lang]!;
        for (final key in criticalKeys) {
          expect(
            stringMap.containsKey(key),
            isTrue,
            reason: 'Key "$key" is missing in language: $lang',
          );
          expect(
            stringMap[key]!.isNotEmpty,
            isTrue,
            reason: 'Value for "$key" is empty in language: $lang',
          );
        }
      }
    });

    test('Turkish dictionary acts as comprehensive master dictionary', () {
      final trMap = AppTranslations.strings['tr']!;
      expect(trMap.length > 50, isTrue);
    });
  });
}
