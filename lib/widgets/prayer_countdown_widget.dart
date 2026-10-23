import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prayer_times_model.dart';
import '../core/constants/app_colors.dart';
import '../providers/locale_provider.dart';

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
    final loc = context.watch<LocaleProvider>();
    final nextInfo = widget.prayerTimes.getNextPrayer();
    final String rawNextName = nextInfo['name'] ?? 'Vakit';
    final String rawCurrentName = nextInfo['currentName'] ?? '';
    final String nextName = loc.prayerName(rawNextName);
    final String currentName = loc.prayerName(rawCurrentName);
    final String nextTimeStr = nextInfo['time'] ?? '';
    final Duration remaining = nextInfo['remaining'] as Duration? ?? Duration.zero;
    final double progress = (nextInfo['progress'] as double? ?? 0.0).clamp(0.0, 1.0);

    final isNegative = remaining.isNegative;
    final safeRemaining = isNegative ? Duration.zero : remaining;

    final hours = safeRemaining.inHours.toString().padLeft(2, '0');
    final minutes = (safeRemaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (safeRemaining.inSeconds % 60).toString().padLeft(2, '0');

    final percentText = (progress * 100).toInt();

    final titleText = loc.isArabic
        ? '${loc.translate('remaining_time_title')} $nextName'
        : (loc.languageCode == 'en'
            ? '${loc.translate('remaining_time_title')} $nextName'
            : '$nextName ${loc.translate('remaining_time_title')}');

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
                      '${loc.translate('current_time_prefix')}: $currentName',
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
                  titleText,
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
              _buildDigitalBox(hours, loc.translate('hours')),
              _buildSeparator(),
              _buildDigitalBox(minutes, loc.translate('minutes')),
              _buildSeparator(),
              _buildDigitalBox(seconds, loc.translate('seconds')),
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
                    loc.formatElapsed(percentText),
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    loc.formatRemaining(safeRemaining),
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
        ],
      ),
    );
  }

  Widget _buildDigitalBox(String value, String label) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 64),
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
