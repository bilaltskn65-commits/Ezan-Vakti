import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'prayer_times_screen.dart';
import 'quran_list_screen.dart';
import 'qibla_screen.dart';
import 'asma_screen.dart';
import 'favorite_ayahs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PrayerTimesScreen(),
    QuranListScreen(),
    QiblaScreen(),
    AsmaScreen(),
    FavoriteAyahsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.goldGlow,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time_outlined),
                activeIcon: Icon(Icons.access_time_filled, color: AppColors.goldGlow),
                label: 'Vakitler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book, color: AppColors.goldGlow),
                label: 'Kuran',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore, color: AppColors.goldGlow),
                label: 'Kıble',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.stars_outlined),
                activeIcon: Icon(Icons.stars, color: AppColors.goldGlow),
                label: 'Esma-ül Hüsna',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border),
                activeIcon: Icon(Icons.bookmark, color: AppColors.goldGlow),
                label: 'Beğenilenler',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
