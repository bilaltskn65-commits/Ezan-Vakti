class AyahModel {
  final int number; // Global ayah number
  final int numberInSurah;
  final int juz;
  final int page;
  final String textAr;
  final String textTr;

  AyahModel({
    required this.number,
    required this.numberInSurah,
    required this.juz,
    required this.page,
    required this.textAr,
    required this.textTr,
  });

  factory AyahModel.fromJson(Map<String, dynamic> jsonAr, Map<String, dynamic>? jsonTr) {
    return AyahModel(
      number: jsonAr['number'] ?? 0,
      numberInSurah: jsonAr['numberInSurah'] ?? 0,
      juz: jsonAr['juz'] ?? 1,
      page: jsonAr['page'] ?? 1,
      textAr: jsonAr['text'] ?? '',
      textTr: jsonTr != null ? (jsonTr['text'] ?? '') : '',
    );
  }

  // Returns formatted 3-digit surah and 3-digit ayah for audio URL
  String getAudioUrl(int surahNumber, String hafizServerPath) {
    final sStr = surahNumber.toString().padLeft(3, '0');
    final aStr = numberInSurah.toString().padLeft(3, '0');
    return 'https://www.everyayah.com/data/$hafizServerPath/$sStr$aStr.mp3';
  }
}

