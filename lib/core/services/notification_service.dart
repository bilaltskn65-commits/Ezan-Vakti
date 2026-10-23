import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/prayer_times_model.dart';
import '../localization/app_translations.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefCountdownSoundKey = 'pref_countdown_sound_key';
  static String _activeCountdownSound = 'uyari_kanun';

  static const String _prefPrayerEntrySoundKey = 'pref_prayer_entry_sound_key';
  static String _activePrayerEntrySound = 'ezan_uyari';

  static Future<String> _getAppLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pref_app_language') ?? 'tr';
  }

  // 1. 45 DAKİKA KALA BİLDİRİM SESLERİ (Mevcut korunanlar + ElevenLabs)
  static const Map<String, ({String title, String desc, String fileName})> availableCountdownSounds = {
    'uyari_kanun': (
      title: 'Otantik Kanun Mızrabı',
      desc: 'Geleneksel Türk kanunu mızrap nağmesi, parlak ve akıcı (Çan içermez)',
      fileName: 'uyari_kanun.wav',
    ),
    'uyari_baglama': (
      title: 'Otantik Saz / Bağlama Tezenesi',
      desc: 'Anadolu irfanı bağlama mızrabı, sıcak ve samimi telli saz nağmesi (Çan içermez)',
      fileName: 'uyari_baglama.wav',
    ),
    'uyari_ahsap_kalimba': (
      title: 'Ahşap Kalimba & Su Damlası',
      desc: 'Sıcak ahşap kalimba ve su damlası melodisi (Sıfır metalik tını)',
      fileName: 'uyari_ahsap_kalimba.wav',
    ),
    'uyari_5_hayye': (
      title: "Hayye ale's-Salâh (Namaza Çağrı)",
      desc: 'Mişari Raşid melodik ezan nidası: Haydin Namaza!',
      fileName: 'uyari_5_hayye.wav',
    ),
    'uyari_ney_huzur': (
      title: 'Huzurlu Ney Sadâsı',
      desc: 'Sakin ve dingin tasavvufi ney üflemesi (ElevenLabs)',
      fileName: 'uyari_ney_huzur.mp3',
    ),
    'uyari_ud_taksim': (
      title: 'Klasik Ud Taksimi',
      desc: 'Geleneksel makam nağmeleriyle akustik ud taksimi (ElevenLabs)',
      fileName: 'uyari_ud_taksim.mp3',
    ),
    'uyari_arp_kanun': (
      title: 'Zarif Arp & Süzülüş',
      desc: 'Yumuşak ve berrak telli çalgı akışı (ElevenLabs)',
      fileName: 'uyari_arp_kanun.mp3',
    ),
    'uyari_sakin_ud': (
      title: 'Sakin Ud Mızrabı',
      desc: 'Sıcak ve huzur verici akustik ud tınıları (ElevenLabs)',
      fileName: 'uyari_sakin_ud.mp3',
    ),
    'uyari_melodik_nida': (
      title: 'Melodik Namaz Nidası (7 sn)',
      desc: '7 saniyelik manevi namaza davet nidası (ElevenLabs)',
      fileName: 'uyari_melodik_nida.mp3',
    ),
    'uyari_kisa_ton': (
      title: 'Kısa Vakit Uyarısı (2 sn)',
      desc: '2 saniyelik sade ve net vakit hatırlatma tonu (ElevenLabs)',
      fileName: 'uyari_kisa_ton.mp3',
    ),
  };

  // 2. EZAN VAKTİ GİRİŞİ SESLERİ (Mevcut korunan + ElevenLabs)
  static const Map<String, ({String title, String desc, String fileName})> availablePrayerEntrySounds = {
    'ezan_uyari': (
      title: 'Mişari Raşid - Ezan Tekbiri (18 sn)',
      desc: 'Mekke/Medine usulü geleneksel ezan başlangıcı: Allahu Ekber Allahu Ekber',
      fileName: 'ezan_uyari.mp3',
    ),
    'ezan_makam_hicaz': (
      title: 'Hicaz Makamı Ezan Nidası (5 sn)',
      desc: 'Kısa, etkileyici ve vakur ezan tekbiri çağrısı (ElevenLabs)',
      fileName: 'ezan_makam_hicaz.mp3',
    ),
    'ezan_makam_rast': (
      title: 'Rast Makamı Ezan Sadâsı (5 sn)',
      desc: 'Manevi ve dingin ezan tekbiri (ElevenLabs)',
      fileName: 'ezan_makam_rast.mp3',
    ),
    'ezan_makam_saba': (
      title: 'Sabâ Makamı Ezan Nidası (5 sn)',
      desc: 'Duygulu, içten ve huzurlu ezan girişi (ElevenLabs)',
      fileName: 'ezan_makam_saba.mp3',
    ),
    'ezan_ney_sadasi': (
      title: 'Derin Ney Sadâsı (4 sn)',
      desc: 'Namaz vaktinin girdiğini müjdeleyen manevi ney üflemesi (ElevenLabs)',
      fileName: 'ezan_ney_sadasi.mp3',
    ),
    'ezan_vakit_bildirim': (
      title: 'Vakit Girdi Melodisi (3 sn)',
      desc: 'Namaz vaktinin girdiğini haber veren zarif melodi (ElevenLabs)',
      fileName: 'ezan_vakit_bildirim.mp3',
    ),
    'ezan_sicak_tini': (
      title: 'Huzurlu Ortam Tınısı (3 sn)',
      desc: 'Yumuşak, sakin ve sıcak manevi vakit sinyali (ElevenLabs)',
      fileName: 'ezan_sicak_tini.mp3',
    ),
  };

  static String get countdownSoundName => _activeCountdownSound;
  static String get countdownChannelId => 'namaz_vakti_countdown_v12_$_activeCountdownSound';
  static const String countdownChannelName = 'Namaz Vaktine 45 Dk Uyarısı';
  static const String countdownChannelDesc =
      'Namaz vaktine 45 dakika kala yapılan sakinleştirici uyarı ve kilit ekranı canlı sayacı';

  // 2. Ezan vakti girişi kanalı (Kullanıcı tarafından seçilebilir)
  static String get prayerEntrySoundName => _activePrayerEntrySound;
  static String get prayerEntryChannelId => 'namaz_vakti_ezan_v12_$_activePrayerEntrySound';
  static const String prayerEntryChannelName = 'Namaz Vakti Girişi (Ezan)';
  static const String prayerEntryChannelDesc =
      'Namaz vakti girdiğinde okunan ezan ve vakit uyarısı';

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();

      // Cihazın yerel zaman dilimini güvenle ayarla
      final now = DateTime.now();
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      } catch (e) {
        final offset = now.timeZoneOffset;
        bool found = false;
        try {
          if (offset.inHours == 3) {
            tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
            found = true;
          }
        } catch (_) {}

        if (!found) {
          try {
            for (final loc in tz.timeZoneDatabase.locations.values) {
              if (loc.currentTimeZone.offset == offset) {
                tz.setLocalLocation(loc);
                found = true;
                break;
              }
            }
          } catch (_) {}
        }

        if (!found) {
          try {
            tz.setLocalLocation(tz.getLocation('UTC'));
          } catch (_) {}
        }
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

      await _notificationsPlugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked / action: ${response.actionId}');
          if (response.actionId == 'action_silence') {
            // Kullanıcı bildirimdeki "Sesi Kapat" aksiyonuna basarsa bildirimi kapat
            if (response.id != null) {
              _notificationsPlugin.cancel(id: response.id!);
            }
          }
        },
      );

      // Kayıtlı 45 dakika ve Ezan bildirim seslerini yükle
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedCountdown = prefs.getString(_prefCountdownSoundKey);
        if (savedCountdown != null && availableCountdownSounds.containsKey(savedCountdown)) {
          _activeCountdownSound = savedCountdown;
        } else {
          _activeCountdownSound = 'uyari_kanun';
        }

        final savedPrayerEntry = prefs.getString(_prefPrayerEntrySoundKey);
        if (savedPrayerEntry != null && availablePrayerEntrySounds.containsKey(savedPrayerEntry)) {
          _activePrayerEntrySound = savedPrayerEntry;
        } else {
          _activePrayerEntrySound = 'ezan_uyari';
        }
      } catch (e) {
        debugPrint('Error loading saved notification sounds: $e');
      }

      // Android bildirim kanallarını oluştur
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        // Eski bildirim kanallarını temizle
        try {
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_channel');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown_v2');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown_v3');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown_v4');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_ezan_v4');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown_v5');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_ezan_v5');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown_v6');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_ezan_v6');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown_v7');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_ezan_v7');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_ezan_v8');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_ezan_v9');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_ezan_v10');
          await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_ezan_v11');
          for (final key in availableCountdownSounds.keys) {
            await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown_v8_$key');
            await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown_v9_$key');
            await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown_v10_$key');
            await androidPlugin.deleteNotificationChannel(channelId: 'namaz_vakti_countdown_v11_$key');
          }
        } catch (_) {}

        // Kanalları oluştur
        await _createCountdownChannel();
        await _createPrayerEntryChannel();
      }

      // Android 13+ bildirim izni ve Android 14+ tam zamanlı alarm izni talebi
      await requestPermissions();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final notif = await androidPlugin.requestNotificationsPermission();
        final canExact = await androidPlugin.canScheduleExactNotifications();
        if (canExact == false) {
          await androidPlugin.requestExactAlarmsPermission();
        }
        return notif ?? false;
      }
    } catch (e) {
      debugPrint('requestPermissions error: $e');
    }
    return false;
  }

  static Future<bool> areNotificationsEnabled() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? true;
      }
    } catch (_) {}
    return true;
  }

  static int getPrayerNotificationId(String prayerName) {
    final clean = prayerName.toLowerCase().trim();
    if (clean.contains('imsak') || clean.contains('i̇msak')) return 101;
    if (clean.contains('güneş') || clean.contains('gunes')) return 102;
    if (clean.contains('öğle') || clean.contains('ogle')) return 103;
    if (clean.contains('ikindi')) return 104;
    if (clean.contains('akşam') || clean.contains('aksam')) return 105;
    if (clean.contains('yatsı') || clean.contains('yatsi')) return 106;
    return 100;
  }

  /// Namaz vakti girdiğinde fırlatılan ezan bildirimi (Seçili Ezan Sesi)
  static NotificationDetails _getNotificationDetails({String? lang}) {
    final soundFile = availablePrayerEntrySounds[_activePrayerEntrySound]?.fileName ?? '$_activePrayerEntrySound.mp3';
    final ticker = AppTranslations.strings[lang]?['notif_ticker_prayer_entered'] ?? 'Ezan vakti girdi';
    return NotificationDetails(
      android: AndroidNotificationDetails(
        prayerEntryChannelId,
        prayerEntryChannelName,
        channelDescription: prayerEntryChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(prayerEntrySoundName),
        audioAttributesUsage: AudioAttributesUsage.notification,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
        ticker: ticker,
        color: const Color(0xFF10B981),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: soundFile,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  static Future<void> _createCountdownChannel() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final countdownChannel = AndroidNotificationChannel(
        countdownChannelId,
        countdownChannelName,
        description: countdownChannelDesc,
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(_activeCountdownSound),
        audioAttributesUsage: AudioAttributesUsage.notification,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
        showBadge: true,
      );
      await androidPlugin.createNotificationChannel(countdownChannel);
    }
  }

  static Future<void> _createPrayerEntryChannel() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final ezanChannel = AndroidNotificationChannel(
        prayerEntryChannelId,
        prayerEntryChannelName,
        description: prayerEntryChannelDesc,
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(_activePrayerEntrySound),
        audioAttributesUsage: AudioAttributesUsage.notification,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
        showBadge: true,
      );
      await androidPlugin.createNotificationChannel(ezanChannel);
    }
  }

  /// 45 dakika bildirim sesini ayarlar ve kanalı günceller
  static Future<void> setCountdownSound(String soundKey) async {
    if (!availableCountdownSounds.containsKey(soundKey)) return;
    _activeCountdownSound = soundKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefCountdownSoundKey, soundKey);
    } catch (e) {
      debugPrint('Error saving countdown sound: $e');
    }
    await _createCountdownChannel();
  }

  /// Ezan vakti bildirim sesini ayarlar ve kanalı günceller
  static Future<void> setPrayerEntrySound(String soundKey) async {
    if (!availablePrayerEntrySounds.containsKey(soundKey)) return;
    _activePrayerEntrySound = soundKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefPrayerEntrySoundKey, soundKey);
    } catch (e) {
      debugPrint('Error saving prayer entry sound: $e');
    }
    await _createPrayerEntryChannel();
  }

  /// Kilit ekranında sabit kalan ve hedeflenen namaz vaktine kadar canlı saniye saniye geri sayan bildirim detayı
  static NotificationDetails _getCountdownNotificationDetails({
    required DateTime targetPrayerTime,
    int? timeoutMs,
    String? lang,
  }) {
    final ticker = AppTranslations.strings[lang]?['notif_ticker_countdown'] ?? 'Namaz vaktine 45 dakika uyarısı';
    final silenceLabel = AppTranslations.strings[lang]?['notif_silence'] ?? '🔕 Sesi Kapat';

    return NotificationDetails(
      android: AndroidNotificationDetails(
        countdownChannelId,
        countdownChannelName,
        channelDescription: countdownChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(countdownSoundName),
        audioAttributesUsage: AudioAttributesUsage.notification,
        onlyAlertOnce: true, // Birden fazla bildirim veya ses tekrarını engeller, tek sefer çalar
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
        ongoing: true, // Kilit ekranında sabit kalır, kullanıcı tarafından kazara silinemez
        autoCancel: false,
        showWhen: true,
        usesChronometer: true, // Android native canlı kronometre
        chronometerCountDown: true, // Namaza kalan süreyi geriye doğru saniye saniye sayar
        when: targetPrayerTime.millisecondsSinceEpoch,
        timeoutAfter: timeoutMs, // Vakit geldiğinde Android OS otomatik olarak bu sayacı kaldırır
        visibility: NotificationVisibility.public, // Kilit ekranında açıkça görünür
        category: AndroidNotificationCategory.reminder,
        ticker: ticker,
        color: const Color(0xFF10B981),
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'action_silence',
            silenceLabel,
            cancelNotification: false,
            showsUserInterface: false,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: availableCountdownSounds[countdownSoundName]?.fileName ?? '$countdownSoundName.wav',
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  /// 45 dakika kala kilit ekranında sabit canlı sayaç bildirimi fırlatır (Tekil ID garantili)
  static Future<void> showApproachingPrayerCountdown({
    required String prayerName,
    required String timeStr,
    required DateTime prayerDateTime,
    int? prayerId,
  }) async {
    try {
      final lang = await _getAppLanguage();
      final displayPrayerName = AppTranslations.prayerNames[lang]?[prayerName] ?? prayerName;
      final notifId = prayerId ?? getPrayerNotificationId(prayerName);
      final remainingMs = prayerDateTime.difference(DateTime.now()).inMilliseconds;

      final title = AppTranslations.strings[lang]?['notif_countdown_live_title']
              ?.replaceAll('{prayer}', displayPrayerName) ??
          '🕌 $displayPrayerName Vaktine Kalan Süre';

      final prefix = AppTranslations.strings[lang]?['notif_time_prefix'] ?? 'Vakit';
      final bodyText = '$prefix: $timeStr';

      await _notificationsPlugin.show(
        id: notifId,
        title: title,
        body: bodyText,
        notificationDetails: _getCountdownNotificationDetails(
          targetPrayerTime: prayerDateTime,
          timeoutMs: remainingMs > 0 ? remainingMs : null,
          lang: lang,
        ),
      );
    } catch (e) {
      debugPrint('showApproachingPrayerCountdown error: $e');
    }
  }

  /// Namaz vakti girdiğinde ezan bildirimi gösterir ("Allahu Ekber Allahu Ekber")
  static Future<void> showPrayerEntryNotification({
    required String prayerName,
    required String timeStr,
    int? prayerId,
  }) async {
    try {
      final lang = await _getAppLanguage();
      final displayPrayerName = AppTranslations.prayerNames[lang]?[prayerName] ?? prayerName;
      final id = prayerId ?? (getPrayerNotificationId(prayerName) + 10);

      final title = AppTranslations.strings[lang]?['notif_prayer_entered_title']
              ?.replaceAll('{prayer}', displayPrayerName) ??
          '🕌 $displayPrayerName Vakti Girdi';

      final body = AppTranslations.strings[lang]?['notif_prayer_entered_body']
              ?.replaceAll('{prayer}', displayPrayerName)
              .replaceAll('{time}', timeStr) ??
          '$displayPrayerName vakti ($timeStr) girmiştir.';

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _getNotificationDetails(lang: lang),
      );
    } catch (e) {
      debugPrint('showPrayerEntryNotification error: $e');
    }
  }

  /// Namaz vakti girdiğinde veya sayaç bittiğinde sabit bildirimi temizler
  static Future<void> cancelCountdownNotification({int? prayerId}) async {
    try {
      if (prayerId != null) {
        await _notificationsPlugin.cancel(id: prayerId);
      } else {
        for (int id = 101; id <= 106; id++) {
          await _notificationsPlugin.cancel(id: id);
        }
      }
    } catch (_) {}
  }

  /// 5 vakit namaz (ve imsak/güneş) için 45 dakika öncesine sabit canlı sayaçlı bildirimleri kurar
  static Future<void> schedulePrayerNotifications(PrayerTimesModel prayerTimes) async {
    try {
      // Önceki zamanlanmış alarmları temizle (101 - 130)
      for (int id = 101; id <= 130; id++) {
        await _notificationsPlugin.cancel(id: id);
      }

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      bool canExact = false;
      if (androidPlugin != null) {
        try {
          canExact = await androidPlugin.canScheduleExactNotifications() ?? false;
        } catch (_) {
          canExact = false;
        }
      }

      final scheduleMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      final lang = await _getAppLanguage();

      final prayers = {
        101: {'name': 'İmsak', 'time': prayerTimes.fajr},
        102: {'name': 'Güneş', 'time': prayerTimes.sunrise},
        103: {'name': 'Öğle', 'time': prayerTimes.dhuhr},
        104: {'name': 'İkindi', 'time': prayerTimes.asr},
        105: {'name': 'Akşam', 'time': prayerTimes.maghrib},
        106: {'name': 'Yatsı', 'time': prayerTimes.isha},
      };

      final now = DateTime.now();

      for (final entry in prayers.entries) {
        final id = entry.key;
        final prayerName = entry.value['name']!;
        final timeStr = entry.value['time']!;
        final displayPrayerName = AppTranslations.prayerNames[lang]?[prayerName] ?? prayerName;

        if (timeStr.isEmpty) continue;

        final countdownTitle = AppTranslations.strings[lang]?['notif_45_min_title']
                ?.replaceAll('{prayer}', displayPrayerName) ??
            '🕌 $displayPrayerName Vaktine 45 Dakika Kaldı';
        final enteredTitle = AppTranslations.strings[lang]?['notif_prayer_entered_title']
                ?.replaceAll('{prayer}', displayPrayerName) ??
            '🕌 $displayPrayerName Vakti Girdi';
        final enteredBody = AppTranslations.strings[lang]?['notif_prayer_entered_body']
                ?.replaceAll('{prayer}', displayPrayerName)
                .replaceAll('{time}', timeStr) ??
            '$displayPrayerName vakti ($timeStr) girmiştir.';
        final timePrefix = AppTranslations.strings[lang]?['notif_time_prefix'] ?? 'Vakit';

        try {
          final cleanTime = timeStr.split(' ').first;
          final parts = cleanTime.split(':');
          if (parts.length < 2) continue;
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          // Hedef namaz vakti
          var prayerDate = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );

          // Eğer bugünkü bu vakit ZATEN GEÇMİŞSE (örn. şu an 19:00, Akşam 18:28 idi),
          // o vakti yarına ertele
          if (prayerDate.isBefore(now)) {
            prayerDate = prayerDate.add(const Duration(days: 1));
          }

          // Vakte 45 dakika kala bildirim saati
          final notifyDate = prayerDate.subtract(const Duration(minutes: 45));

          final notifyTz = tz.TZDateTime(
            tz.local,
            notifyDate.year,
            notifyDate.month,
            notifyDate.day,
            notifyDate.hour,
            notifyDate.minute,
          );

          final prayerTz = tz.TZDateTime(
            tz.local,
            prayerDate.year,
            prayerDate.month,
            prayerDate.day,
            prayerDate.hour,
            prayerDate.minute,
          );

          // 1. 45 DAKİKA KALA UYARISI / SABİT GERİ SAYIM:
          if (notifyDate.isAfter(now.add(const Duration(seconds: 5)))) {
            // Henüz 45 dakika öncesi gelmemiş, geleceğe tam zamanlı alarm kur
            final remainingMs = prayerDate.difference(notifyDate).inMilliseconds;
            try {
              await _notificationsPlugin.zonedSchedule(
                id: id,
                title: countdownTitle,
                body: '$timePrefix: $timeStr',
                scheduledDate: notifyTz,
                notificationDetails: _getCountdownNotificationDetails(
                  targetPrayerTime: prayerDate,
                  timeoutMs: remainingMs,
                  lang: lang,
                ),
                androidScheduleMode: scheduleMode,
              );
            } catch (e) {
              await _notificationsPlugin.zonedSchedule(
                id: id,
                title: countdownTitle,
                body: '$timePrefix: $timeStr',
                scheduledDate: notifyTz,
                notificationDetails: _getCountdownNotificationDetails(
                  targetPrayerTime: prayerDate,
                  timeoutMs: remainingMs,
                  lang: lang,
                ),
                androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              );
            }
          } else if (now.isAfter(notifyDate) && now.isBefore(prayerDate)) {
            // Şu an tam bu namazın 45 dakikalık penceresi içindeyiz!
            // Canlı kilit ekranı sayacını hemen göster
            await showApproachingPrayerCountdown(
              prayerName: prayerName,
              timeStr: timeStr,
              prayerDateTime: prayerDate,
              prayerId: id,
            );
          }

          // 2. TAM NAMAZ VAKTİNDE GİRİŞ BİLDİRİMİ (Allahu Ekber Allahu Ekber):
          if (prayerDate.isAfter(now.add(const Duration(seconds: 5)))) {
            final entryId = id + 10;
            try {
              await _notificationsPlugin.zonedSchedule(
                id: entryId,
                title: enteredTitle,
                body: enteredBody,
                scheduledDate: prayerTz,
                notificationDetails: _getNotificationDetails(lang: lang),
                androidScheduleMode: scheduleMode,
              );
            } catch (e) {
              await _notificationsPlugin.zonedSchedule(
                id: entryId,
                title: enteredTitle,
                body: enteredBody,
                scheduledDate: prayerTz,
                notificationDetails: _getNotificationDetails(lang: lang),
                androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              );
            }
          }
        } catch (e) {
          debugPrint('Namaz bildirimi ($prayerName) kurulamadı: $e');
        }
      }

      debugPrint('Namaz vakitleri bildirimleri ve canlı kilit ekranı sayacı güncellendi.');
    } catch (e) {
      debugPrint('schedulePrayerNotifications error: $e');
    }
  }

  // =========================================================================
  // GEÇİCİ BİLDİRİM TEST METOTLARI (Test tamamlandıktan sonra kaldırılacak)
  // =========================================================================

  /// Test 1: 45 Dakika Uyarısı ve Canlı Kilit Ekranı Sayacı (Anında Çal)
  static Future<String?> testNowCountdownNotification() async {
    try {
      final enabled = await areNotificationsEnabled();
      if (!enabled) {
        await requestPermissions();
      }
      final lang = await _getAppLanguage();
      final displayPrayerName = AppTranslations.prayerNames[lang]?['Akşam'] ?? 'Akşam';
      final title = AppTranslations.strings[lang]?['notif_test_countdown_title']
              ?.replaceAll('{prayer}', displayPrayerName) ??
          '🕌 $displayPrayerName Vaktine Kalan Süre (Test)';
      final body = AppTranslations.strings[lang]?['notif_test_countdown_body']
              ?.replaceAll('{time}', '18:28') ??
          'Vakit: 18:28 (Canlı Sayaç Testi)';

      final dummyPrayerTime = DateTime.now().add(const Duration(minutes: 5));
      await _notificationsPlugin.show(
        id: 991,
        title: title,
        body: body,
        notificationDetails: _getCountdownNotificationDetails(
          targetPrayerTime: dummyPrayerTime,
          timeoutMs: 5 * 60 * 1000,
          lang: lang,
        ),
      );
      return null;
    } catch (e, stack) {
      debugPrint('testNowCountdownNotification error: $e\n$stack');
      return e.toString();
    }
  }

  /// Test 2: Vakit Girişi Ezan Bildirimi (Allahu Ekber Allahu Ekber - Anında Çal)
  static Future<String?> testNowPrayerEntryNotification() async {
    try {
      final enabled = await areNotificationsEnabled();
      if (!enabled) {
        await requestPermissions();
      }
      final lang = await _getAppLanguage();
      final displayPrayerName = AppTranslations.prayerNames[lang]?['Akşam'] ?? 'Akşam';
      final title = AppTranslations.strings[lang]?['notif_test_prayer_entered_title']
              ?.replaceAll('{prayer}', displayPrayerName) ??
          '🕌 $displayPrayerName Vakti Girdi (Test)';
      final body = AppTranslations.strings[lang]?['notif_test_prayer_entered_body']
              ?.replaceAll('{prayer}', displayPrayerName) ??
          '$displayPrayerName vakti girmiştir (Ezan Testi).';

      await _notificationsPlugin.show(
        id: 992,
        title: title,
        body: body,
        notificationDetails: _getNotificationDetails(lang: lang),
      );
      return null;
    } catch (e, stack) {
      debugPrint('testNowPrayerEntryNotification error: $e\n$stack');
      return e.toString();
    }
  }

  /// Test 3: 10 Saniye Sonra 45 Dk Uyarısı Alarmı (Arka Plan / Kilit Ekranı Testi)
  static Future<String?> testScheduledCountdownNotification({int seconds = 10}) async {
    try {
      await requestPermissions();
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      bool canExact = false;
      if (androidPlugin != null) {
        canExact = await androidPlugin.canScheduleExactNotifications() ?? false;
      }
      final scheduleMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      final lang = await _getAppLanguage();
      final displayPrayerName = AppTranslations.prayerNames[lang]?['Akşam'] ?? 'Akşam';
      final title = AppTranslations.strings[lang]?['notif_test_10s_countdown_title']
              ?.replaceAll('{prayer}', displayPrayerName) ??
          '🕌 $displayPrayerName Vaktine 45 Dk Kaldı (10 sn Test Alarmı)';
      final body = AppTranslations.strings[lang]?['notif_test_10s_countdown_body']
              ?.replaceAll('{time}', '18:28') ??
          'Vakit: 18:28 (10 sn sonra çalan alarm testi)';

      final targetDate = DateTime.now().add(Duration(seconds: seconds));
      final targetTz = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));
      final dummyPrayer = targetDate.add(const Duration(minutes: 5));

      await _notificationsPlugin.zonedSchedule(
        id: 993,
        title: title,
        body: body,
        scheduledDate: targetTz,
        notificationDetails: _getCountdownNotificationDetails(
          targetPrayerTime: dummyPrayer,
          timeoutMs: (seconds + 300) * 1000,
          lang: lang,
        ),
        androidScheduleMode: scheduleMode,
      );
      return null;
    } catch (e, stack) {
      debugPrint('testScheduledCountdownNotification error: $e\n$stack');
      return e.toString();
    }
  }

  /// Test 4: 10 Saniye Sonra Ezan Giriş Alarmı (Arka Plan / Kilit Ekranı Testi)
  static Future<String?> testScheduledPrayerEntryNotification({int seconds = 10}) async {
    try {
      await requestPermissions();
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      bool canExact = false;
      if (androidPlugin != null) {
        canExact = await androidPlugin.canScheduleExactNotifications() ?? false;
      }
      final scheduleMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      final lang = await _getAppLanguage();
      final displayPrayerName = AppTranslations.prayerNames[lang]?['Akşam'] ?? 'Akşam';
      final title = AppTranslations.strings[lang]?['notif_test_10s_ezan_title']
              ?.replaceAll('{prayer}', displayPrayerName) ??
          '🕌 $displayPrayerName Vakti Girdi (10 sn Test Alarmı)';
      final body = AppTranslations.strings[lang]?['notif_test_10s_ezan_body']
              ?.replaceAll('{prayer}', displayPrayerName) ??
          '$displayPrayerName vakti girmiştir (10 sn sonra çalan ezan sesi).';

      final targetTz = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

      await _notificationsPlugin.zonedSchedule(
        id: 994,
        title: title,
        body: body,
        scheduledDate: targetTz,
        notificationDetails: _getNotificationDetails(lang: lang),
        androidScheduleMode: scheduleMode,
      );
      return null;
    } catch (e, stack) {
      debugPrint('testScheduledPrayerEntryNotification error: $e\n$stack');
      return e.toString();
    }
  }

  /// Test Bildirimlerini Temizle
  static Future<void> clearTestNotifications() async {
    try {
      await _notificationsPlugin.cancel(id: 991);
      await _notificationsPlugin.cancel(id: 992);
      await _notificationsPlugin.cancel(id: 993);
      await _notificationsPlugin.cancel(id: 994);
    } catch (_) {}
  }
  // =========================================================================
}
