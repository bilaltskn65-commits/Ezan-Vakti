import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization/app_translations.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'pref_app_language';
  String _languageCode = 'tr';

  LocaleProvider() {
    _loadSavedLanguage();
  }

  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);
  bool get isArabic => _languageCode == 'ar';

  String get languageName {
    switch (_languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'tr':
      default:
        return 'Türkçe';
    }
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && (saved == 'tr' || saved == 'en' || saved == 'ar')) {
      if (_languageCode != saved) {
        _languageCode = saved;
        notifyListeners();
      }
    }
  }

  Future<void> setLanguage(String code) async {
    if (code != 'tr' && code != 'en' && code != 'ar') return;
    if (_languageCode == code) return;

    _languageCode = code;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }

  /// Translates a UI key with optional parameters
  String translate(String key, {Map<String, String>? params}) {
    final dict = AppTranslations.strings[_languageCode];
    String text = dict?[key] ?? AppTranslations.strings['tr']?[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    return text;
  }

  /// Translates prayer name given standard Turkish key (e.g. 'İmsak', 'Öğle')
  String prayerName(String turkishKey) {
    final names = AppTranslations.prayerNames[_languageCode];
    if (names != null && names.containsKey(turkishKey)) {
      return names[turkishKey]!;
    }
    return AppTranslations.prayerNames['tr']?[turkishKey] ?? turkishKey;
  }

  /// Helper to format elapsed time string
  String formatElapsed(int percent) {
    final raw = translate('elapsed_text');
    return raw.replaceAll('{percent}', percent.toString());
  }

  /// Helper to format remaining duration
  String formatRemaining(Duration safeRemaining) {
    if (safeRemaining.inHours > 0) {
      final raw = translate('time_remaining_format_hm');
      return raw
          .replaceAll('{h}', safeRemaining.inHours.toString())
          .replaceAll('{m}', (safeRemaining.inMinutes % 60).toString());
    } else {
      final raw = translate('time_remaining_format_ms');
      return raw
          .replaceAll('{m}', (safeRemaining.inMinutes % 60).toString())
          .replaceAll('{s}', (safeRemaining.inSeconds % 60).toString());
    }
  }

  /// Helper to interpolate generic parameters
  String interpolate(String key, Map<String, String> values) {
    String text = translate(key);
    values.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }
}
