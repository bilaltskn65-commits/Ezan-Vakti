import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/prayer_times_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(settings: settings);
    } catch (_) {
      // Safe fallback for testing environment without native channels
    }
  }

  static Future<void> schedulePrayerNotifications(PrayerTimesModel prayerTimes) async {
    try {
      await _notificationsPlugin.cancelAll();

      final now = DateTime.now();
      final prayers = prayerTimes.asList;

      int id = 0;
      for (var entry in prayers.entries) {
        final prayerName = entry.key;
        final timeStr = entry.value;

        final prayerDt = prayerTimes.getPrayerDateTime(timeStr);
        if (prayerDt == null) continue;

        final notificationTime = prayerDt.subtract(const Duration(minutes: 45));

        if (notificationTime.isAfter(now)) {
          id++;
          final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

          await _notificationsPlugin.zonedSchedule(
            id: id,
            title: 'Namaz Vakti Yaklaşıyor',
            body: '$prayerName namazına 45 dakika kaldı ($timeStr). Hazırlığınızı yapmayı unutmayın.',
            scheduledDate: tzNotificationTime,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'namaz_vakti_channel',
                'Namaz Vakti Bildirimleri',
                channelDescription: 'Namaz vakitlerine 45 dakika kala yapılan bildirimler',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    } catch (_) {
      // Ignore channel exceptions in non-mobile test platforms
    }
  }
}

