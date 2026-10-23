import 'package:flutter_test/flutter_test.dart';
import 'package:ezan_vakti/core/constants/turkey_cities.dart';

void main() {
  group('TurkeyCities Tests', () {
    test('TurkeyCities.all contains exactly 81 cities', () {
      expect(TurkeyCities.all.length, 81);
    });

    test('Plate numbers are unique and range from 1 to 81', () {
      final plates = TurkeyCities.all.map((c) => c.plate).toSet();
      expect(plates.length, 81);
      for (int i = 1; i <= 81; i++) {
        expect(plates.contains(i), isTrue, reason: 'Missing plate number: $i');
      }
    });

    test('All coordinates are within Turkey geographic bounds', () {
      for (final city in TurkeyCities.all) {
        expect(
          city.lat >= 35.0 && city.lat <= 43.0,
          isTrue,
          reason: 'Latitude out of bounds for ${city.name}: ${city.lat}',
        );
        expect(
          city.lng >= 25.0 && city.lng <= 45.0,
          isTrue,
          reason: 'Longitude out of bounds for ${city.name}: ${city.lng}',
        );
      }
    });

    test('City names are non-empty and searchable', () {
      final istanbul = TurkeyCities.all.firstWhere((c) => c.name == 'İstanbul');
      expect(istanbul.plate, 34);

      final ankara = TurkeyCities.all.firstWhere((c) => c.name == 'Ankara');
      expect(ankara.plate, 6);

      final izmir = TurkeyCities.all.firstWhere((c) => c.name == 'İzmir');
      expect(izmir.plate, 35);
    });

    test('Alphabetical sorting with Turkish collation works', () {
      final sorted = List<TurkeyCity>.from(TurkeyCities.all)
        ..sort((a, b) => a.name.compareTo(b.name));

      expect(sorted.first.name, 'Adana');
      expect(sorted.length, 81);
    });
  });
}
