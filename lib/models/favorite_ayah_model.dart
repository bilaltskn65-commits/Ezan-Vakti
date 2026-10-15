import 'dart:convert';

class FavoriteAyahModel {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String textAr;
  final String textTr;
  final DateTime addedAt;

  FavoriteAyahModel({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.textAr,
    required this.textTr,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'textAr': textAr,
      'textTr': textTr,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FavoriteAyahModel.fromMap(Map<String, dynamic> map) {
    return FavoriteAyahModel(
      surahNumber: map['surahNumber'] ?? 1,
      surahName: map['surahName'] ?? '',
      ayahNumber: map['ayahNumber'] ?? 1,
      textAr: map['textAr'] ?? '',
      textTr: map['textTr'] ?? '',
      addedAt: map['addedAt'] != null
          ? DateTime.tryParse(map['addedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FavoriteAyahModel.fromJson(String source) =>
      FavoriteAyahModel.fromMap(json.decode(source));
}
