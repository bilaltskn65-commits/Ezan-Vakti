import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prayer_times_model.dart';
import '../core/constants/app_colors.dart';

class PrayerCountdownWidget extends StatefulWidget {
  final PrayerTimesModel prayerTimes;

  const PrayerCountdownWidget({
    super.key,
    required this.prayerTimes,
  });

  @override
  State<PrayerCountdownWidget> createState() => _PrayerCountdownWidgetState();
}

class _PrayerCountdownWidgetState extends State<PrayerCountdownWidget> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Update every second for live countdown
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextInfo = widget.prayerTimes.getNextPrayer();
    final String nextName = nextInfo['name'] ?? 'Vakit';
    final String nextTimeStr = nextInfo['time'] ?? '';
    final String currentName = nextInfo['currentName'] ?? '';
    final Duration remaining = nextInfo['remaining'] as Duration? ?? Duration.zero;
    final double progress = (nextInfo['progress'] as double? ?? 0.0).clamp(0.0, 1.0);

    final isNegative = remaining.isNegative;
    final safeRemaining = isNegative ? Duration.zero : remaining;

    final hours = safeRemaining.inHours.toString().padLeft(2, '0');
    final minutes = (safeRemaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (safeRemaining.inSeconds % 60).toString().padLeft(2, '0');

    final percentText = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.bgDark3,
            AppColors.emeraldDark,
            Color(0xFF07271E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldDark.withValues(alpha: 0.5),
            blurRadius: 22,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Current and Next Prayer Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current prayer badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.bgDark1.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wb_sunny_outlined, color: AppColors.emeraldAccent, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Şu an: $currentName',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Next prayer badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_filled, color: AppColors.bgDark1, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '$nextName: $nextTimeStr',
                      style: const TextStyle(
                        color: AppColors.bgDark1,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Title
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.goldGlow, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$nextName Vaktine Kalan Süre',
                  style: const TextStyle(
                    color: AppColors.goldGlow,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Big Glowing Digital Time Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDigitalBox(hours, 'SAAT'),
              _buildSeparator(),
              _buildDigitalBox(minutes, 'DAKİKA'),
              _buildSeparator(),
              _buildDigitalBox(seconds, 'SANİYE'),
            ],
          ),

          const SizedBox(height: 18),

          // Progress Bar with Elapsed Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vaktin %$percentText\'i geçti',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    safeRemaining.inHours > 0
                        ? '${safeRemaining.inHours} sa ${safeRemaining.inMinutes % 60} dk kaldı'
                        : '${safeRemaining.inMinutes % 60} dk ${safeRemaining.inSeconds % 60} sn kaldı',
                    style: const TextStyle(
                      color: AppColors.emeraldAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 7,
                  color: AppColors.bgDark1,
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.emeraldAccent,
                                AppColors.goldPrimary,
                                AppColors.goldGlow,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Notification status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgDark1.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.notifications_active, color: AppColors.emeraldAccent, size: 14),
                SizedBox(width: 6),
                Text(
                  '45 dakika kala bildirim ve ezan vakti uyarısı aktif',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalBox(String value, String label) {
    return Column(
      children: [
        Container(
          constraints: const Duration(milliseconds: 100) == Duration.zero ? null : const BoxConstraints(minWidth: 64),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgDark1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.75),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldPrimary.withValues(alpha: 0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.goldGlow,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: const Text(
        ':',
        style: TextStyle(
          color: AppColors.goldPrimary,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
