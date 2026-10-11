import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../core/constants/app_colors.dart';

class LocationSearchModal extends StatefulWidget {
  const LocationSearchModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationSearchModal(),
    );
  }

  @override
  State<LocationSearchModal> createState() => _LocationSearchModalState();
}

class _LocationSearchModalState extends State<LocationSearchModal> {
  final TextEditingController _cityController = TextEditingController();

  final List<String> popularCities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Adana',
    'Konya',
    'Gaziantep',
    'Şanlıurfa',
    'Trabzon',
    'Kayseri',
    'Mekke',
    'Medine',
    'Kudüs',
    'Londra',
    'Berlin',
  ];

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.bgDark1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.emeraldAccent, width: 1.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Konum Seçimi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Auto Location Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () {
                prayerProvider.fetchPrayerTimesWithAutoLocation();
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.emeraldDark, AppColors.bgDark3],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.emeraldAccent),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.my_location, color: AppColors.emeraldAccent, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Otomatik Konumu Kullan (GPS)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _cityController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Şehir adı yazın (Örn: Konya, Berlin)...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.goldPrimary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle, color: AppColors.emeraldAccent),
                  onPressed: () {
                    if (_cityController.text.trim().isNotEmpty) {
                      prayerProvider.fetchPrayerTimesForCity(
                        _cityController.text.trim(),
                        'Türkiye',
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.goldPrimary),
                ),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  prayerProvider.fetchPrayerTimesForCity(val.trim(), 'Türkiye');
                  Navigator.pop(context);
                }
              },
            ),
          ),

          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Popüler Şehirler',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: popularCities.length,
              itemBuilder: (context, index) {
                final city = popularCities[index];
                return InkWell(
                  onTap: () {
                    prayerProvider.fetchPrayerTimesForCity(city, 'Türkiye');
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      city,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

