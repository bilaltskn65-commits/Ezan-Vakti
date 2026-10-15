import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/prayer_times_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();

      // Cihazın yerel zaman dilimini tespit et ve timezone kütüphanesine ata
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      } catch (e) {
        try {
          tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
        } catch (_) {}
      }

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

      // Android 13+ (API 33+) ve Android 14+ (API 34+) bildirim ve tam zamanlı alarm izinlerini iste
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('NotificationService init error: $e');
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

        // Vakte 45 dakika kala bildirim zamanı
        var targetDt = prayerDt;
        var notificationTime = targetDt.subtract(const Duration(minutes: 45));

        // Eğer bugünün 45 dk öncesi vakti zaten geçmişse, sonraki günün vaktine kur
        if (notificationTime.isBefore(now)) {
          targetDt = targetDt.add(const Duration(days: 1));
          notificationTime = targetDt.subtract(const Duration(minutes: 45));
        }

        id++;
        final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: 'Namaz Vakti Yaklaşıyor',
          body: '$prayerName vaktine 45 dakika kaldı ($timeStr). Hazırlığınızı yapmayı unutmayın.',
          scheduledDate: tzNotificationTime,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'namaz_vakti_channel',
              'Namaz Vakti Bildirimleri',
              channelDescription: 'Namaz vakitlerine 45 dakika kala yapılan bildirimler',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
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
    } catch (e) {
      debugPrint('schedulePrayerNotifications error: $e');
    }
  }
}


