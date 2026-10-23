import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_vakti/core/constants/quran_surahs_data.dart';
import 'package:ezan_vakti/core/services/quran_service.dart';

void main() {
  group('Quran Data & Translations Tests', () {
    test('kAllSurahs contains exactly 114 Surahs', () {
      expect(kAllSurahs.length, 114);
    });

    test('Surah numbering is continuous from 1 to 114', () {
      for (int i = 0; i < kAllSurahs.length; i++) {
        expect(kAllSurahs[i].number, i + 1);
        expect(kAllSurahs[i].nameTr.isNotEmpty, isTrue);
        expect(kAllSurahs[i].nameAr.isNotEmpty, isTrue);
        expect(kAllSurahs[i].numberOfAyahs > 0, isTrue);
      }
    });

    test('Special surahs check: Fatiha, Bakara, Yasin, Ihlas, Nas', () {
      final fatiha = kAllSurahs.first;
      expect(fatiha.number, 1);
      expect(fatiha.nameTr, 'Fâtiha');
      expect(fatiha.numberOfAyahs, 7);

      final bakara = kAllSurahs[1];
      expect(bakara.number, 2);
      expect(bakara.nameTr, 'Bakara');
      expect(bakara.numberOfAyahs, 286);

      final yasin = kAllSurahs.firstWhere((s) => s.number == 36);
      expect(yasin.nameTr, 'Yâsîn');
      expect(yasin.numberOfAyahs, 83);

      final ihlas = kAllSurahs.firstWhere((s) => s.number == 112);
      expect(ihlas.nameTr, 'İhlâs');
      expect(ihlas.numberOfAyahs, 4);

      final nas = kAllSurahs.last;
      expect(nas.number, 114);
      expect(nas.nameTr, 'Nâs');
      expect(nas.numberOfAyahs, 6);
    });

    test('Total number of ayahs in the Holy Quran is 6236', () {
      final totalAyahs = kAllSurahs.fold<int>(0, (sum, surah) => sum + surah.numberOfAyahs);
      expect(totalAyahs, 6236);
    });

    test('QuranTranslations contains supported language options', () {
      expect(QuranTranslations.languages.isNotEmpty, isTrue);
      final langCodes = QuranTranslations.languages.map((l) => l.code).toList();
      expect(langCodes, contains('tr'));
      expect(langCodes, contains('en'));
      expect(langCodes, contains('de'));
      expect(langCodes, contains('fr'));
    });

    test('QuranTranslations.all has valid translation entries', () {
      expect(QuranTranslations.all.isNotEmpty, isTrue);
      for (final t in QuranTranslations.all) {
        expect(t.id.isNotEmpty, isTrue);
        expect(t.name.isNotEmpty, isTrue);
        expect(t.author.isNotEmpty, isTrue);
        expect(t.languageCode.isNotEmpty, isTrue);
      }
    });
  });
}
