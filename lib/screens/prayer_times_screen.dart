import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../core/constants/app_colors.dart';
import 'location_search_modal.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final prayerTimes = prayerProvider.prayerTimes;

    return Scaffold(
      backgroundColor: AppColors.bgDark1,
      appBar: AppBar(
        title: const Text(
          'Namaz Vakitleri',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: AppColors.goldPrimary),
            tooltip: 'Konum Değiştir',
            onPressed: () => LocationSearchModal.show(context),
          ),
        ],
      ),
      body: prayerProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.goldPrimary),
            )
          : prayerTimes == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Vakitler yüklenemedi',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => prayerProvider.fetchPrayerTimesWithAutoLocation(),
                        child: const Text('Tekrar Dene'),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Location Bar Button
                      InkWell(
                        onTap: () => LocationSearchModal.show(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                prayerProvider.isAutoLocation
                                    ? Icons.my_location
                                    : Icons.location_city,
                                color: AppColors.emeraldAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  prayerProvider.locationName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const Text(
                                'Değiştir',
                                style: TextStyle(
                                  color: AppColors.goldGlow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Next Prayer Countdown Hero Card
                      Builder(builder: (context) {
                        final nextInfo = prayerTimes.getNextPrayer();
                        final String nextName = nextInfo['name'];
                        final String nextTimeStr = nextInfo['time'];
                        final Duration remaining = nextInfo['remaining'];

                        final hours = remaining.inHours.toString().padLeft(2, '0');
                        final minutes =
                            (remaining.inMinutes % 60).toString().padLeft(2, '0');
                        final seconds =
                            (remaining.inSeconds % 60).toString().padLeft(2, '0');

                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.bgDark3, AppColors.emeraldDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: AppColors.goldPrimary.withValues(alpha: 0.6)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.emeraldDark.withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.access_time_filled,
                                      color: AppColors.goldGlow, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sonraki Vakit: $nextName ($nextTimeStr)',
                                    style: const TextStyle(
                                      color: AppColors.goldGlow,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Countdown Timer Display
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildTimeBox(hours, 'SAAT'),
                                  const Text(' : ',
                                      style: TextStyle(
                                          color: AppColors.goldPrimary,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold)),
                                  _buildTimeBox(minutes, 'DAKİKA'),
                                  const Text(' : ',
                                      style: TextStyle(
                                          color: AppColors.goldPrimary,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold)),
                                  _buildTimeBox(seconds, 'SANİYE'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.bgDark1.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.emeraldAccent),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.notifications_active,
                                        color: AppColors.emeraldAccent, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      '45 dakika kala bildirim aktif',
                                      style: TextStyle(
                                        color: AppColors.emeraldAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      const Text(
                        'Bugünün Vakitleri',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Prayer Cards List
                      ...prayerTimes.asList.entries.map((entry) {
                        final prayerName = entry.key;
                        final timeStr = entry.value;
                        final nextInfo = prayerTimes.getNextPrayer();
                        final isNext = (nextInfo['name'] == prayerName);

                        IconData icon;
                        switch (prayerName) {
                          case 'İmsak':
                            icon = Icons.nightlight_round;
                            break;
                          case 'Güneş':
                            icon = Icons.wb_twilight;
                            break;
                          case 'Öğle':
                            icon = Icons.wb_sunny;
                            break;
                          case 'İkindi':
                            icon = Icons.wb_cloudy;
                            break;
                          case 'Akşam':
                            icon = Icons.nights_stay;
                            break;
                          case 'Yatsı':
                            icon = Icons.bedtime;
                            break;
                          default:
                            icon = Icons.access_time;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: isNext
                                ? AppColors.emeraldDark.withValues(alpha: 0.6)
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isNext ? AppColors.goldGlow : AppColors.glassBorder,
                              width: isNext ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    isNext ? AppColors.goldGlow : AppColors.bgDark3,
                                child: Icon(
                                  icon,
                                  color: isNext ? AppColors.bgDark1 : AppColors.goldPrimary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                prayerName,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight:
                                      isNext ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  color: isNext
                                      ? AppColors.goldGlow
                                      : AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTimeBox(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgDark1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.8)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.goldGlow,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

