import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/services/notification_service.dart';
import '../providers/locale_provider.dart';
import 'prayer_times_screen.dart';
import 'quran_list_screen.dart';
import 'qibla_screen.dart';
import 'asma_screen.dart';
import 'favorite_ayahs_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.requestPermissions();
    });
  }

  final List<Widget> _pages = const [
    PrayerTimesScreen(),
    QuranListScreen(),
    QiblaScreen(),
    AsmaScreen(),
    FavoriteAyahsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgDark3,
          border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            iconSize: 22,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.goldGlow,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            unselectedLabelStyle: const TextStyle(fontSize: 9),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.access_time_outlined),
                activeIcon: const Icon(Icons.access_time_filled, color: AppColors.goldGlow),
                label: loc.translate('nav_prayers'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu_book_outlined),
                activeIcon: const Icon(Icons.menu_book, color: AppColors.goldGlow),
                label: loc.translate('nav_quran'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.explore_outlined),
                activeIcon: const Icon(Icons.explore, color: AppColors.goldGlow),
                label: loc.translate('nav_qibla'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.stars_outlined),
                activeIcon: const Icon(Icons.stars, color: AppColors.goldGlow),
                label: loc.translate('nav_asma'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bookmark_border),
                activeIcon: const Icon(Icons.bookmark, color: AppColors.goldGlow),
                label: loc.translate('nav_favorites'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings, color: AppColors.goldGlow),
                label: loc.translate('nav_settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
