class TurkeyCity {
  final int plate;
  final String name;
  final double lat;
  final double lng;

  const TurkeyCity({
    required this.plate,
    required this.name,
    required this.lat,
    required this.lng,
  });
}

class TurkeyCities {
  static const List<TurkeyCity> all = [
    TurkeyCity(plate: 1, name: 'Adana', lat: 37.0000, lng: 35.3213),
    TurkeyCity(plate: 2, name: 'Adıyaman', lat: 37.7648, lng: 38.2786),
    TurkeyCity(plate: 3, name: 'Afyonkarahisar', lat: 38.7507, lng: 30.5567),
    TurkeyCity(plate: 4, name: 'Ağrı', lat: 39.7191, lng: 43.0503),
    TurkeyCity(plate: 5, name: 'Amasya', lat: 40.6534, lng: 35.8331),
    TurkeyCity(plate: 6, name: 'Ankara', lat: 39.9334, lng: 32.8597),
    TurkeyCity(plate: 7, name: 'Antalya', lat: 36.8969, lng: 30.7133),
    TurkeyCity(plate: 8, name: 'Artvin', lat: 41.1828, lng: 41.8183),
    TurkeyCity(plate: 9, name: 'Aydın', lat: 37.8560, lng: 27.8416),
    TurkeyCity(plate: 10, name: 'Balıkesir', lat: 39.6484, lng: 27.8826),
    TurkeyCity(plate: 11, name: 'Bilecik', lat: 40.1419, lng: 29.9793),
    TurkeyCity(plate: 12, name: 'Bingöl', lat: 38.8854, lng: 40.4983),
    TurkeyCity(plate: 13, name: 'Bitlis', lat: 38.4006, lng: 42.1095),
    TurkeyCity(plate: 14, name: 'Bolu', lat: 40.7358, lng: 31.6061),
    TurkeyCity(plate: 15, name: 'Burdur', lat: 37.7203, lng: 30.2908),
    TurkeyCity(plate: 16, name: 'Bursa', lat: 40.1885, lng: 29.0610),
    TurkeyCity(plate: 17, name: 'Çanakkale', lat: 40.1553, lng: 26.4142),
    TurkeyCity(plate: 18, name: 'Çankırı', lat: 40.6013, lng: 33.6134),
    TurkeyCity(plate: 19, name: 'Çorum', lat: 40.5506, lng: 34.9556),
    TurkeyCity(plate: 20, name: 'Denizli', lat: 37.7765, lng: 29.0864),
    TurkeyCity(plate: 21, name: 'Diyarbakır', lat: 37.9144, lng: 40.2306),
    TurkeyCity(plate: 22, name: 'Edirne', lat: 41.6772, lng: 26.5557),
    TurkeyCity(plate: 23, name: 'Elazığ', lat: 38.6810, lng: 39.2264),
    TurkeyCity(plate: 24, name: 'Erzincan', lat: 39.7500, lng: 39.5000),
    TurkeyCity(plate: 25, name: 'Erzurum', lat: 39.9043, lng: 41.2679),
    TurkeyCity(plate: 26, name: 'Eskişehir', lat: 39.7767, lng: 30.5206),
    TurkeyCity(plate: 27, name: 'Gaziantep', lat: 37.0662, lng: 37.3833),
    TurkeyCity(plate: 28, name: 'Giresun', lat: 40.9128, lng: 38.3895),
    TurkeyCity(plate: 29, name: 'Gümüşhane', lat: 40.4600, lng: 39.4814),
    TurkeyCity(plate: 30, name: 'Hakkâri', lat: 37.5833, lng: 43.7333),
    TurkeyCity(plate: 31, name: 'Hatay', lat: 36.4018, lng: 36.3498),
    TurkeyCity(plate: 32, name: 'Isparta', lat: 37.7648, lng: 30.5566),
    TurkeyCity(plate: 33, name: 'Mersin', lat: 36.8121, lng: 34.6415),
    TurkeyCity(plate: 34, name: 'İstanbul', lat: 41.0082, lng: 28.9784),
    TurkeyCity(plate: 35, name: 'İzmir', lat: 38.4237, lng: 27.1428),
    TurkeyCity(plate: 36, name: 'Kars', lat: 40.6167, lng: 43.1000),
    TurkeyCity(plate: 37, name: 'Kastamonu', lat: 41.3887, lng: 33.7827),
    TurkeyCity(plate: 38, name: 'Kayseri', lat: 38.7312, lng: 35.4787),
    TurkeyCity(plate: 39, name: 'Kırklareli', lat: 41.7333, lng: 27.2167),
    TurkeyCity(plate: 40, name: 'Kırşehir', lat: 39.1425, lng: 34.1709),
    TurkeyCity(plate: 41, name: 'Kocaeli', lat: 40.8533, lng: 29.8815),
    TurkeyCity(plate: 42, name: 'Konya', lat: 37.8667, lng: 32.4833),
    TurkeyCity(plate: 43, name: 'Kütahya', lat: 39.4167, lng: 29.9833),
    TurkeyCity(plate: 44, name: 'Malatya', lat: 38.3552, lng: 38.3095),
    TurkeyCity(plate: 45, name: 'Manisa', lat: 38.6191, lng: 27.4289),
    TurkeyCity(plate: 46, name: 'Kahramanmaraş', lat: 37.5858, lng: 36.9371),
    TurkeyCity(plate: 47, name: 'Mardin', lat: 37.3212, lng: 40.7245),
    TurkeyCity(plate: 48, name: 'Muğla', lat: 37.2153, lng: 28.3636),
    TurkeyCity(plate: 49, name: 'Muş', lat: 38.7432, lng: 41.5064),
    TurkeyCity(plate: 50, name: 'Nevşehir', lat: 38.6244, lng: 34.7239),
    TurkeyCity(plate: 51, name: 'Niğde', lat: 37.9667, lng: 34.6833),
    TurkeyCity(plate: 52, name: 'Ordu', lat: 40.9839, lng: 37.8764),
    TurkeyCity(plate: 53, name: 'Rize', lat: 41.0201, lng: 40.5234),
    TurkeyCity(plate: 54, name: 'Sakarya', lat: 40.7569, lng: 30.3783),
    TurkeyCity(plate: 55, name: 'Samsun', lat: 41.2928, lng: 36.3313),
    TurkeyCity(plate: 56, name: 'Siirt', lat: 37.9333, lng: 41.9500),
    TurkeyCity(plate: 57, name: 'Sinop', lat: 42.0231, lng: 35.1531),
    TurkeyCity(plate: 58, name: 'Sivas', lat: 39.7477, lng: 37.0179),
    TurkeyCity(plate: 59, name: 'Tekirdağ', lat: 40.9833, lng: 27.5167),
    TurkeyCity(plate: 60, name: 'Tokat', lat: 40.3167, lng: 36.5500),
    TurkeyCity(plate: 61, name: 'Trabzon', lat: 41.0015, lng: 39.7178),
    TurkeyCity(plate: 62, name: 'Tunceli', lat: 39.1079, lng: 39.5401),
    TurkeyCity(plate: 63, name: 'Şanlıurfa', lat: 37.1674, lng: 38.7955),
    TurkeyCity(plate: 64, name: 'Uşak', lat: 38.6823, lng: 29.4082),
    TurkeyCity(plate: 65, name: 'Van', lat: 38.4891, lng: 43.4089),
    TurkeyCity(plate: 66, name: 'Yozgat', lat: 39.8181, lng: 34.8147),
    TurkeyCity(plate: 67, name: 'Zonguldak', lat: 41.4564, lng: 31.7987),
    TurkeyCity(plate: 68, name: 'Aksaray', lat: 38.3687, lng: 34.0370),
    TurkeyCity(plate: 69, name: 'Bayburt', lat: 40.2552, lng: 40.2249),
    TurkeyCity(plate: 70, name: 'Karaman', lat: 37.1759, lng: 33.2287),
    TurkeyCity(plate: 71, name: 'Kırıkkale', lat: 39.8468, lng: 33.5153),
    TurkeyCity(plate: 72, name: 'Batman', lat: 37.8812, lng: 41.1292),
    TurkeyCity(plate: 73, name: 'Şırnak', lat: 37.5164, lng: 42.4611),
    TurkeyCity(plate: 74, name: 'Bartın', lat: 41.6344, lng: 32.3375),
    TurkeyCity(plate: 75, name: 'Ardahan', lat: 41.1105, lng: 42.7022),
    TurkeyCity(plate: 76, name: 'Iğdır', lat: 39.9196, lng: 44.0450),
    TurkeyCity(plate: 77, name: 'Yalova', lat: 40.6500, lng: 29.2667),
    TurkeyCity(plate: 78, name: 'Karabük', lat: 41.2061, lng: 32.6204),
    TurkeyCity(plate: 79, name: 'Kilis', lat: 36.7184, lng: 37.1212),
    TurkeyCity(plate: 80, name: 'Osmaniye', lat: 37.0742, lng: 36.2472),
    TurkeyCity(plate: 81, name: 'Düzce', lat: 40.8438, lng: 31.1565),
  ];

  static int compareTurkish(String a, String b) {
    const turkishAlphabet = 'abcçdefgğhıijklmnoöprsştuüvyz';
    final aLower = a.toLowerCase();
    final bLower = b.toLowerCase();
    final minLen = aLower.length < bLower.length ? aLower.length : bLower.length;
    for (int i = 0; i < minLen; i++) {
      final charA = aLower[i];
      final charB = bLower[i];
      if (charA != charB) {
        final indexA = turkishAlphabet.indexOf(charA);
        final indexB = turkishAlphabet.indexOf(charB);
        if (indexA != -1 && indexB != -1) {
          return indexA.compareTo(indexB);
        }
        return charA.compareTo(charB);
      }
    }
    return aLower.length.compareTo(bLower.length);
  }

  static List<TurkeyCity> get alphabetical {
    final list = List<TurkeyCity>.from(all);
    list.sort((a, b) => compareTurkish(a.name, b.name));
    return list;
  }

  static TurkeyCity? findByName(String name) {
    final clean = _normalize(name);
    for (final c in all) {
      if (_normalize(c.name) == clean) return c;
    }
    return null;
  }

  static List<TurkeyCity> search(String query) {
    final source = alphabetical;
    if (query.trim().isEmpty) return source;
    final clean = _normalize(query);
    return source.where((c) {
      return _normalize(c.name).contains(clean) ||
          c.plate.toString() == clean ||
          c.plate.toString().padLeft(2, '0') == clean;
    }).toList();
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'c')
        .replaceAll('â', 'a')
        .replaceAll('Â', 'a')
        .trim();
  }
}
