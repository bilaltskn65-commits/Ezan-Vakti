import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../providers/locale_provider.dart';

class NotificationTestModal extends StatefulWidget {
  const NotificationTestModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationTestModal(),
    );
  }

  @override
  State<NotificationTestModal> createState() => _NotificationTestModalState();
}

class _NotificationTestModalState extends State<NotificationTestModal> {
  bool _notificationsEnabled = true;
  AudioPlayer? _audioPlayer;
  bool _isPlayingInAppAudio = false;
  String? _playingSoundKey;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final enabled = await NotificationService.areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
      });
    }
  }

  Future<void> _playInAppAudio(String assetPath) async {
    try {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.stop();
      setState(() {
        _isPlayingInAppAudio = true;
        _playingSoundKey = assetPath;
      });
      await _audioPlayer!.play(AssetSource(assetPath));
      _audioPlayer!.onPlayerComplete.listen((_) {
        if (mounted && _playingSoundKey == assetPath) {
          setState(() {
            _isPlayingInAppAudio = false;
            _playingSoundKey = null;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlayingInAppAudio = false;
          _playingSoundKey = null;
        });
        _showFeedback('Hoparlör çalma hatası: $e', isSuccess: false);
      }
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer?.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isPlayingInAppAudio = false;
        _playingSoundKey = null;
      });
    }
  }

  void _showFeedback(String message, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final activeCountdownSound = NotificationService.availableCountdownSounds[NotificationService.countdownSoundName];
    final activeEzanSound = NotificationService.availablePrayerEntrySounds[NotificationService.prayerEntrySoundName];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDark2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1.5),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 14,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header (without "Geçici")
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active, color: AppColors.goldGlow, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('test_modal_title'),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        loc.translate('test_modal_sub'),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Permission Warning if disabled
            if (!_notificationsEnabled) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        loc.translate('perm_tile_sub'),
                        style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await NotificationService.requestPermissions();
                        await _checkPermission();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        loc.translate('allow'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Active Sounds Summary Card (Informational only - sound selection done in Ayarlar)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgDark3,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.goldGlow, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        loc.translate('test_active_sounds_title'),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildActiveSoundRow(
                    icon: Icons.music_note,
                    iconColor: AppColors.goldGlow,
                    label: loc.translate('test_active_countdown'),
                    soundTitle: activeCountdownSound?.title ?? '45 Dk Sesi',
                    onPreview: () {
                      final fn = activeCountdownSound?.fileName ?? 'uyari_kanun.wav';
                      _playInAppAudio('audio/$fn');
                    },
                  ),
                  const Divider(color: Colors.white10, height: 16),
                  _buildActiveSoundRow(
                    icon: Icons.mosque_outlined,
                    iconColor: AppColors.emeraldAccent,
                    label: loc.translate('test_active_ezan'),
                    soundTitle: activeEzanSound?.title ?? 'Ezan Vakti Sesi',
                    onPreview: () {
                      final fn = activeEzanSound?.fileName ?? 'ezan_uyari.mp3';
                      _playInAppAudio('audio/$fn');
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.translate('test_active_sub'),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            // Test 1: 45 dk uyarısı (Anında)
            _buildTestCard(
              icon: Icons.music_note,
              iconColor: AppColors.goldGlow,
              title: loc.translate('test_card_countdown_title'),
              subtitle: loc.translate('test_card_countdown_sub'),
              buttonText: loc.translate('test_btn_play_instant'),
              onPressed: () async {
                final err = await NotificationService.testNowCountdownNotification();
                if (err != null) {
                  _showFeedback('Bildirim hatası: $err', isSuccess: false);
                } else {
                  _showFeedback(
                    '${activeCountdownSound?.title ?? ''} bildirimi fırlatıldı! Kilit ekranı sayacını kontrol edebilirsiniz.',
                  );
                }
              },
              onPreviewAudio: () {
                final fn = activeCountdownSound?.fileName ?? 'uyari_kanun.wav';
                _playInAppAudio('audio/$fn');
              },
              previewLabel: loc.translate('test_btn_preview'),
            ),
            const SizedBox(height: 10),

            // Test 2: Ezan Girişi (Anında)
            _buildTestCard(
              icon: Icons.mosque_outlined,
              iconColor: AppColors.emeraldAccent,
              title: loc.translate('test_card_ezan_title'),
              subtitle: loc.translate('test_card_ezan_sub'),
              buttonText: loc.translate('test_btn_play_ezan'),
              onPressed: () async {
                final err = await NotificationService.testNowPrayerEntryNotification();
                if (err != null) {
                  _showFeedback('Ezan bildirimi hatası: $err', isSuccess: false);
                } else {
                  _showFeedback(
                    '${activeEzanSound?.title ?? ''} ezan bildirimi fırlatıldı!',
                  );
                }
              },
              onPreviewAudio: () {
                final fn = activeEzanSound?.fileName ?? 'ezan_uyari.mp3';
                _playInAppAudio('audio/$fn');
              },
              previewLabel: loc.translate('test_btn_preview'),
            ),
            const SizedBox(height: 10),

            // Test 3: 10 Saniye Sonra 45 Dk Uyarısı (Arka Plan Testi)
            _buildTestCard(
              icon: Icons.timer_outlined,
              iconColor: Colors.amberAccent,
              title: loc.translate('test_card_schedule_countdown_title'),
              subtitle: loc.translate('test_card_schedule_countdown_sub'),
              buttonText: loc.translate('test_btn_set_10s'),
              onPressed: () async {
                final err = await NotificationService.testScheduledCountdownNotification(seconds: 10);
                if (err != null) {
                  _showFeedback('Alarm hatası: $err', isSuccess: false);
                } else {
                  _showFeedback(
                    '10 sn alarmı kuruldu! Ekranı kapatıp bekleyebilirsiniz.',
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            // Test 4: 10 Saniye Sonra Ezan (Arka Plan Testi)
            _buildTestCard(
              icon: Icons.alarm,
              iconColor: AppColors.goldPrimary,
              title: loc.translate('test_card_schedule_ezan_title'),
              subtitle: loc.translate('test_card_schedule_ezan_sub'),
              buttonText: loc.translate('test_btn_set_10s'),
              onPressed: () async {
                final err = await NotificationService.testScheduledPrayerEntryNotification(seconds: 10);
                if (err != null) {
                  _showFeedback('Ezan alarmı hatası: $err', isSuccess: false);
                } else {
                  _showFeedback(
                    'Ezan alarmı 10 sn sonraya kuruldu! Ekranı kapatıp bekleyebilirsiniz.',
                  );
                }
              },
            ),
            const SizedBox(height: 14),

            // In-app audio stop button if playing
            if (_isPlayingInAppAudio) ...[
              ElevatedButton.icon(
                onPressed: _stopAudio,
                icon: const Icon(Icons.stop),
                label: Text(loc.translate('test_btn_stop')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Clear test notifications
            OutlinedButton.icon(
              onPressed: () async {
                await NotificationService.clearTestNotifications();
                _showFeedback(loc.translate('test_btn_clear'));
              },
              icon: const Icon(Icons.cleaning_services_outlined, size: 18),
              label: Text(loc.translate('test_btn_clear')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSoundRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String soundTitle,
    required VoidCallback onPreview,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              Text(
                soundTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            _isPlayingInAppAudio ? Icons.volume_up : Icons.play_circle_outline,
            color: iconColor,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onPreview,
        ),
      ],
    );
  }

  Widget _buildTestCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    VoidCallback? onPreviewAudio,
    String? previewLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor.withValues(alpha: 0.2),
                  foregroundColor: iconColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: iconColor.withValues(alpha: 0.5)),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          if (onPreviewAudio != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onPreviewAudio,
                icon: Icon(Icons.volume_up, size: 16, color: iconColor),
                label: Text(
                  previewLabel ?? 'Hoparlörden Önizle',
                  style: TextStyle(fontSize: 11, color: iconColor),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
