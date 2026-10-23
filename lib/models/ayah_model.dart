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

  String get translation => textTr;

  // Returns formatted 3-digit surah and 3-digit ayah for audio URL
  String getAudioUrl(int surahNumber, String hafizServerPath) {
    int audioAyahNum = numberInSurah;
    if (surahNumber == 1) {
      if (numberInSurah == 1) {
        audioAyahNum = 2; // Elhamdülillâhi Rabbi'l-âlemîn
      } else if (numberInSurah == 2) {
        audioAyahNum = 3; // Er-Rahmâni'r-Rahîm
      } else if (numberInSurah == 3) {
        audioAyahNum = 4; // Mâliki yevmi'd-dîn
      } else if (numberInSurah == 4) {
        audioAyahNum = 5; // İyyâke na'büdü ve iyyâke neste'în
      } else if (numberInSurah == 5) {
        audioAyahNum = 6; // İhdine's-sırâta'l-müstakîm
      } else {
        audioAyahNum = 7; // Sırâtallezîne en'amte...
      }
    }
    final sStr = surahNumber.toString().padLeft(3, '0');
    final aStr = audioAyahNum.toString().padLeft(3, '0');
    return 'https://www.everyayah.com/data/$hafizServerPath/$sStr$aStr.mp3';
  }
}

