class SurahModel {
  final int number;
  final String nameAr;
  final String nameTr;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType; // Meccan / Medinan

  const SurahModel({
    required this.number,
    required this.nameAr,
    required this.nameTr,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] ?? 0,
      nameAr: json['name'] ?? '',
      nameTr: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      revelationType: json['revelationType'] ?? 'Meccan',
    );
  }

  String get revelationTypeTr => revelationType.toLowerCase() == 'meccan' ? 'Mekke' : 'Medine';

  String getLocalizedRevelationType(String lang) {
    final isMeccan = revelationType.toLowerCase() == 'meccan';
    if (lang == 'en') return isMeccan ? 'Meccan' : 'Medinan';
    if (lang == 'ar') return isMeccan ? 'مكية' : 'مدنية';
    return isMeccan ? 'Mekke' : 'Medine';
  }

  String getLocalizedAyahs(String lang) {
    if (lang == 'en') return '$numberOfAyahs Verses';
    if (lang == 'ar') return '$numberOfAyahs آية';
    return '$numberOfAyahs Ayet';
  }

  String getLocalizedName(String lang) {
    if (lang == 'ar' && nameAr.isNotEmpty) return nameAr;
    return nameTr;
  }
}
