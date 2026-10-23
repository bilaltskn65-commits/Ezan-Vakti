import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

extension LocalizationExtension on BuildContext {
  /// Quick access to LocaleProvider
  LocaleProvider get loc => watch<LocaleProvider>();

  /// Translate key with optional params (e.g. context.tr('ayah_count', {'count': '7'}))
  String tr(String key, [Map<String, String>? params]) {
    return watch<LocaleProvider>().translate(key, params: params);
  }

  /// Translate prayer name (e.g. 'İmsak', 'Öğle')
  String prayerName(String turkishKey) {
    return watch<LocaleProvider>().prayerName(turkishKey);
  }

  /// Current language code ('tr', 'en', 'ar')
  String get langCode => watch<LocaleProvider>().languageCode;

  /// Whether current language is Arabic (RTL)
  bool get isArabic => watch<LocaleProvider>().isArabic;
}
