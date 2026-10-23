import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_vakti/models/surah_model.dart';
import 'package:ezan_vakti/models/ayah_model.dart';
import 'package:ezan_vakti/models/hafiz_model.dart';
import 'package:ezan_vakti/models/favorite_ayah_model.dart';

void main() {
  group('SurahModel Tests', () {
    final mockSurahJson = {
      'number': 1,
      'name': 'سُورَةُ الفَاتِحَةِ',
      'englishName': 'Fâtiha',
      'englishNameTranslation': 'The Opening',
      'numberOfAyahs': 7,
      'revelationType': 'Meccan',
    };

    test('SurahModel.fromJson parses fields correctly', () {
      final surah = SurahModel.fromJson(mockSurahJson);

      expect(surah.number, 1);
      expect(surah.nameAr, 'سُورَةُ الفَاتِحَةِ');
      expect(surah.nameTr, 'Fâtiha');
      expect(surah.englishNameTranslation, 'The Opening');
      expect(surah.numberOfAyahs, 7);
      expect(surah.revelationType, 'Meccan');
      expect(surah.revelationTypeTr, 'Mekke');
    });

    test('Localized getters for revelation type, ayahs, and name', () {
      final surah = SurahModel.fromJson(mockSurahJson);

      expect(surah.getLocalizedRevelationType('tr'), 'Mekke');
      expect(surah.getLocalizedRevelationType('en'), 'Meccan');
      expect(surah.getLocalizedRevelationType('ar'), 'مكية');

      expect(surah.getLocalizedAyahs('tr'), '7 Ayet');
      expect(surah.getLocalizedAyahs('en'), '7 Verses');
      expect(surah.getLocalizedAyahs('ar'), '7 آية');

      expect(surah.getLocalizedName('tr'), 'Fâtiha');
      expect(surah.getLocalizedName('ar'), 'سُورَةُ الفَاتِحَةِ');
    });
  });

  group('AyahModel Tests', () {
    final mockAr = {
      'number': 1,
      'numberInSurah': 1,
      'juz': 1,
      'page': 1,
      'text': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
    };
    final mockTr = {
      'text': 'Rahmân ve Rahîm olan Allah\'ın adıyla.',
    };

    test('AyahModel.fromJson parses Arabic and Turkish text correctly', () {
      final ayah = AyahModel.fromJson(mockAr, mockTr);

      expect(ayah.number, 1);
      expect(ayah.numberInSurah, 1);
      expect(ayah.juz, 1);
      expect(ayah.page, 1);
      expect(ayah.textAr, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ');
      expect(ayah.textTr, 'Rahmân ve Rahîm olan Allah\'ın adıyla.');
      expect(ayah.translation, ayah.textTr);
    });

    test('AyahModel.getAudioUrl offsets Surah Fatiha audio index properly', () {
      final hafizPath = 'Alafasy_128kbps';

      // For Surah 1: numberInSurah 1 maps to 001002.mp3
      final ayah1 = AyahModel.fromJson(
        {'number': 1, 'numberInSurah': 1, 'text': ''},
        null,
      );
      expect(ayah1.getAudioUrl(1, hafizPath), 'https://www.everyayah.com/data/Alafasy_128kbps/001002.mp3');

      // For Surah 2 (Baqarah): numberInSurah 1 maps to 002001.mp3
      final ayahBaqarah = AyahModel.fromJson(
        {'number': 8, 'numberInSurah': 1, 'text': ''},
        null,
      );
      expect(ayahBaqarah.getAudioUrl(2, hafizPath), 'https://www.everyayah.com/data/Alafasy_128kbps/002001.mp3');
    });
  });

  group('FavoriteAyahModel & HafizModel Tests', () {
    test('FavoriteAyahModel serializes and deserializes cleanly', () {
      final fav = FavoriteAyahModel(
        surahNumber: 2,
        surahName: 'Bakara',
        ayahNumber: 255,
        textAr: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
        textTr: 'Allah, O\'ndan başka ilah yoktur; Diridir, her şeyi ayakta tutandır.',
      );

      final jsonString = fav.toJson();
      final fromJsonFav = FavoriteAyahModel.fromJson(jsonString);

      expect(fromJsonFav.surahNumber, 2);
      expect(fromJsonFav.surahName, 'Bakara');
      expect(fromJsonFav.ayahNumber, 255);
      expect(fromJsonFav.textAr, fav.textAr);
      expect(fromJsonFav.textTr, fav.textTr);
    });

    test('HafizList has valid server paths and names for all 10 reciters', () {
      expect(HafizList.reciters.length, 10);
      for (final hafiz in HafizList.reciters) {
        expect(hafiz.id.isNotEmpty, isTrue);
        expect(hafiz.nameTr.isNotEmpty, isTrue);
        expect(hafiz.serverPath.isNotEmpty, isTrue);
        expect(hafiz.description.isNotEmpty, isTrue);
      }
    });
  });
}
