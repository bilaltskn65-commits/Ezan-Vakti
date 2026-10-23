import '../core/constants/asma_translations.dart';

class AsmaModel {
  final int id;
  final String nameAr;
  final String nameTr;
  final String meaning;
  final String virtue;
  final int ebced;

  const AsmaModel({
    required this.id,
    required this.nameAr,
    required this.nameTr,
    required this.meaning,
    required this.virtue,
    required this.ebced,
  });

  String getLocalizedName(String langCode) {
    if (langCode == 'ar') return nameAr;
    if (langCode == 'en') return AsmaTranslations.getName(id, 'en') ?? nameTr;
    return nameTr;
  }

  String getLocalizedMeaning(String langCode) {
    if (langCode == 'ar') return AsmaTranslations.getMeaning(id, 'ar') ?? meaning;
    if (langCode == 'en') return AsmaTranslations.getMeaning(id, 'en') ?? meaning;
    return meaning;
  }

  String getLocalizedVirtue(String langCode) {
    if (langCode == 'ar') return AsmaTranslations.getVirtue(id, 'ar') ?? virtue;
    if (langCode == 'en') return AsmaTranslations.getVirtue(id, 'en') ?? virtue;
    return virtue;
  }
}
