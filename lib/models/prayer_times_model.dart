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

  // Returns next prayer name, current prayer name, remaining duration and progress (0.0 to 1.0)
  Map<String, dynamic> getNextPrayer() {
    final now = DateTime.now();
    final list = asList;
    final keys = list.keys.toList();

    String? nextName;
    DateTime? nextTime;
    String? currentName;
    DateTime? currentTime;

    for (int i = 0; i < keys.length; i++) {
      final dt = getPrayerDateTime(list[keys[i]]!);
      if (dt != null && dt.isAfter(now)) {
        nextName = keys[i];
        nextTime = dt;
        if (i > 0) {
          currentName = keys[i - 1];
          currentTime = getPrayerDateTime(list[currentName]!);
        } else {
          // before Imsak today, current is yesterday's Yatsı
          currentName = 'Yatsı';
          final yatsiDt = getPrayerDateTime(isha);
          currentTime = yatsiDt?.subtract(const Duration(days: 1));
        }
        break;
      }
    }

    // If all prayers today have passed, next is tomorrow's Fajr
    if (nextName == null || nextTime == null) {
      currentName = 'Yatsı';
      currentTime = getPrayerDateTime(isha);
      nextName = 'İmsak';
      final tomorrowFajr = getPrayerDateTime(fajr);
      if (tomorrowFajr != null) {
        nextTime = tomorrowFajr.add(const Duration(days: 1));
      } else {
        nextTime = now.add(const Duration(hours: 6));
      }
    }

    currentTime ??= nextTime.subtract(const Duration(hours: 3));
    final totalSeconds = nextTime.difference(currentTime).inSeconds;
    final elapsedSeconds = now.difference(currentTime).inSeconds;
    double progress = (totalSeconds > 0) ? (elapsedSeconds / totalSeconds) : 0.0;
    progress = progress.clamp(0.0, 1.0);

    final durationLeft = nextTime.difference(now);
    return {
      'name': nextName,
      'time': list[nextName] ?? fajr,
      'currentName': currentName ?? 'Vakit',
      'currentTime': list[currentName] ?? '',
      'dateTime': nextTime,
      'remaining': durationLeft,
      'progress': progress,
    };
  }
}

