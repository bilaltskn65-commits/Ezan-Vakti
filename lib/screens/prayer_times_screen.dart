import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../core/constants/app_colors.dart';
import '../widgets/prayer_countdown_widget.dart';
import '../widgets/app_widgets_modal.dart';
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
          'Ezan Vakti & Kuran',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.widgets_outlined, color: AppColors.emeraldAccent),
            tooltip: 'Ana Ekran Widget\'ları',
            onPressed: () => AppWidgetsModal.show(context),
          ),
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
              : RefreshIndicator(
                  color: AppColors.goldGlow,
                  backgroundColor: AppColors.cardBg,
                  onRefresh: () async {
                    await prayerProvider.fetchPrayerTimesWithAutoLocation();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 95),
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

                      // 1. Ana ekranda ezana ne kadar kaldığını gösteren widget (Canlı saniye sayaçlı & ilerleme çubuklu)
                      PrayerCountdownWidget(prayerTimes: prayerTimes),

                      const SizedBox(height: 24),

                      // Günün Vakitleri Başlığı
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                backgroundColor: isNext ? AppColors.goldGlow : AppColors.bgDark3,
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
                                  fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  color: isNext ? AppColors.goldGlow : AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
    );
  }
}
