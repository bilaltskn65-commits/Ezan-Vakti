import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezan_vakti/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleProvider Tests', () {
    test('Defaults to Turkish when no saved language exists', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();

      expect(provider.languageCode, 'tr');
      expect(provider.locale.languageCode, 'tr');
      expect(provider.isArabic, isFalse);
      expect(provider.languageName, 'Türkçe');
    });

    test('Loads previously saved language from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'pref_app_language': 'en'});
      final provider = LocaleProvider();

      // Give async microtask time to load preferences
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(provider.languageCode, 'en');
      expect(provider.locale.languageCode, 'en');
      expect(provider.languageName, 'English');
    });

    test('setLanguage updates languageCode and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();

      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.setLanguage('ar');

      expect(provider.languageCode, 'ar');
      expect(provider.isArabic, isTrue);
      expect(provider.languageName, 'العربية');
      expect(notified, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pref_app_language'), 'ar');
    });

    test('setLanguage ignores invalid language codes', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();

      await provider.setLanguage('xyz');
      expect(provider.languageCode, 'tr'); // should stay 'tr'
    });

    test('translate and prayerName return correct values', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();

      final title = provider.translate('app_title');
      expect(title.isNotEmpty, isTrue);

      final imsakTr = provider.prayerName('İmsak');
      expect(imsakTr, 'İmsak');

      await provider.setLanguage('en');
      final imsakEn = provider.prayerName('İmsak');
      expect(imsakEn, 'Fajr');
    });

    test('formatRemaining formats hours and minutes or minutes and seconds', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();

      final formattedHm = provider.formatRemaining(const Duration(hours: 2, minutes: 15));
      expect(formattedHm.contains('2'), isTrue);
      expect(formattedHm.contains('15'), isTrue);

      final formattedMs = provider.formatRemaining(const Duration(minutes: 5, seconds: 30));
      expect(formattedMs.contains('5'), isTrue);
      expect(formattedMs.contains('30'), isTrue);
    });
  });
}
