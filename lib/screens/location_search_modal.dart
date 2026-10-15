import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/turkey_cities.dart';

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
  List<TurkeyCity> _filteredCities = TurkeyCities.alphabetical;

  final List<String> popularCityNames = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Konya',
    'Adana',
    'Gaziantep',
    'Şanlıurfa',
    'Trabzon',
    'Kayseri',
    'Diyarbakır',
  ];

  @override
  void initState() {
    super.initState();
    _filteredCities = TurkeyCities.alphabetical;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredCities = TurkeyCities.search(query);
    });
  }

  void _selectCity(String cityName) {
    final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
    prayerProvider.fetchPrayerTimesForCity(cityName, 'Türkiye');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.bgDark1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.emeraldAccent, width: 1.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.location_city, color: AppColors.goldPrimary, size: 22),
              SizedBox(width: 8),
              Text(
                'Türkiye Şehirleri (81 İl)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.emeraldDark, AppColors.bgDark3],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.emeraldAccent),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.my_location, color: AppColors.emeraldAccent, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mevcut Konumu Kullan (GPS)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 14),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _cityController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Şehir veya plaka ara (Örn: Konya, 42, Van)...',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.goldPrimary),
                suffixIcon: _cityController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _cityController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.goldPrimary),
                ),
              ),
            ),
          ),

          // Popular Cities Horizontal Chips
          if (_cityController.text.isEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: popularCityNames.length,
                itemBuilder: (context, index) {
                  final cityName = popularCityNames[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      backgroundColor: AppColors.cardBg,
                      side: const BorderSide(color: AppColors.glassBorder),
                      label: Text(
                        cityName,
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () => _selectCity(cityName),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _cityController.text.isEmpty
                      ? 'Tüm İller (${TurkeyCities.all.length})'
                      : 'Bulunan İller (${_filteredCities.length})',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Plaka / İl Adı',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.glassBorder, height: 1),

          // 81 Cities List
          Expanded(
            child: _filteredCities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text(
                          '"${_cityController.text}" bulunamadı',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = _filteredCities[index];
                      final plateStr = city.plate.toString().padLeft(2, '0');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.5)),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.bgDark3, AppColors.emeraldDark],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.6)),
                            ),
                            child: Text(
                              plateStr,
                              style: const TextStyle(
                                color: AppColors.goldGlow,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          title: Text(
                            city.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            'Türkiye • Enlem: ${city.lat.toStringAsFixed(2)}°',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.goldPrimary,
                            size: 20,
                          ),
                          onTap: () => _selectCity(city.name),
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
