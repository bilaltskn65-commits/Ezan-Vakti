class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String timezone;
  final String locationName;

  PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.timezone,
    required this.locationName,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json, String location) {
    final timings = json['data']['timings'];
    final dateInfo = json['data']['date'];
    return PrayerTimesModel(
      fajr: timings['Fajr'] ?? '',
      sunrise: timings['Sunrise'] ?? '',
      dhuhr: timings['Dhuhr'] ?? '',
      asr: timings['Asr'] ?? '',
      maghrib: timings['Maghrib'] ?? '',
      isha: timings['Isha'] ?? '',
      date: dateInfo['readable'] ?? '',
      timezone: json['data']['meta']?['timezone'] ?? '',
      locationName: location,
    );
  }

  Map<String, String> get asList => {
        'İmsak': fajr,
        'Güneş': sunrise,
        'Öğle': dhuhr,
        'İkindi': asr,
        'Akşam': maghrib,
        'Yatsı': isha,
      };

  // Helper method to get DateTime object for a specific prayer string HH:mm today
  DateTime? getPrayerDateTime(String timeStr) {
    try {
      final now = DateTime.now();
      final cleanTime = timeStr.split(' ').first; // remove any (EST) suffix
      final parts = cleanTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  // Returns next prayer name and remaining duration
  Map<String, dynamic> getNextPrayer() {
    final now = DateTime.now();
    final list = asList;

    String? nextName;
    DateTime? nextTime;

    for (var entry in list.entries) {
      final dt = getPrayerDateTime(entry.value);
      if (dt != null && dt.isAfter(now)) {
        nextName = entry.key;
        nextTime = dt;
        break;
      }
    }

    // If all prayers today have passed, next is tomorrow's Fajr
    if (nextName == null || nextTime == null) {
      nextName = 'İmsak';
      final tomorrowFajr = getPrayerDateTime(fajr);
      if (tomorrowFajr != null) {
        nextTime = tomorrowFajr.add(const Duration(days: 1));
      } else {
        nextTime = now.add(const Duration(hours: 6));
      }
    }

    final durationLeft = nextTime.difference(now);
    return {
      'name': nextName,
      'time': list[nextName] ?? fajr,
      'dateTime': nextTime,
      'remaining': durationLeft,
    };
  }
}

