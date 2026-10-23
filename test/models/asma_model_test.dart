import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_vakti/core/constants/asma_data.dart';
import 'package:ezan_vakti/core/constants/asma_translations.dart';

void main() {
  group('Asma-ul Husna Data and Model Tests', () {
    test('AsmaData contains exactly 99 names of Allah', () {
      expect(AsmaData.names.length, 99);
    });

    test('All 99 names have valid consecutive IDs (1 to 99)', () {
      for (int i = 0; i < AsmaData.names.length; i++) {
        final asma = AsmaData.names[i];
        expect(asma.id, i + 1);
        expect(asma.nameAr.isNotEmpty, isTrue);
        expect(asma.nameTr.isNotEmpty, isTrue);
        expect(asma.meaning.isNotEmpty, isTrue);
        expect(asma.virtue.isNotEmpty, isTrue);
        expect(asma.ebced > 0, isTrue);
      }
    });

    test('AsmaModel localized methods return localized text for TR, EN and AR', () {
      final first = AsmaData.names.first; // Er-Rahman (ID: 1)

      expect(first.getLocalizedName('tr'), 'Er-Rahmân');
      expect(first.getLocalizedName('ar'), 'الرَّحْمَنُ');
      expect(first.getLocalizedName('en').isNotEmpty, isTrue);

      expect(first.getLocalizedMeaning('tr'), first.meaning);
      expect(first.getLocalizedMeaning('en').isNotEmpty, isTrue);

      expect(first.getLocalizedVirtue('tr'), first.virtue);
      expect(first.getLocalizedVirtue('en').isNotEmpty, isTrue);
    });

    test('AsmaTranslations gracefully handles edge cases', () {
      expect(AsmaTranslations.getName(1, 'en'), isNotNull);
      expect(AsmaTranslations.getName(999, 'en'), isNull);
      expect(AsmaTranslations.getMeaning(999, 'ar'), isNull);
    });
  });
}
