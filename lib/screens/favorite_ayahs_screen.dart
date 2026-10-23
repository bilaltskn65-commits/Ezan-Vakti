import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quran_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/localization_extension.dart';
import 'ayah_post_generator_screen.dart';
import 'quran_detail_screen.dart';

class FavoriteAyahsScreen extends StatelessWidget {
  const FavoriteAyahsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quranProvider = Provider.of<QuranProvider>(context);
    final favorites = quranProvider.favorites;

    return Scaffold(
      backgroundColor: AppColors.bgDark1,
      appBar: AppBar(
        title: Text(
          context.tr('fav_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        size: 44,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.tr('fav_empty_title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('fav_empty_sub'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final fav = favorites[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.bgDark3, AppColors.emeraldDark],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.goldPrimary),
                            ),
                            child: Text(
                              '${fav.surahName} • ${context.tr('ayah_number_format', {'number': '${fav.ayahNumber}'})}',
                              style: const TextStyle(
                                color: AppColors.goldGlow,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Builder(builder: (context) {
                                final isPinned = quranProvider.isAyahPinned(
                                  fav.surahNumber,
                                  fav.ayahNumber,
                                );
                                return IconButton(
                                  icon: Icon(
                                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                    color: isPinned ? AppColors.goldGlow : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                  tooltip: isPinned ? context.tr('fav_unpin_tooltip') : context.tr('fav_pin_tooltip'),
                                  onPressed: () async {
                                    if (isPinned) {
                                      await quranProvider.unpinAyah();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.tr('fav_unpinned_snack'),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                            ),
                                            backgroundColor: AppColors.bgDark3,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              side: const BorderSide(color: AppColors.glassBorder),
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } else {
                                      await quranProvider.pinAyah(fav);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              context.tr('fav_pinned_snack', {
                                                'surah': fav.surahName,
                                                'number': '${fav.ayahNumber}',
                                              }),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                            ),
                                            backgroundColor: AppColors.bgDark3,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              side: BorderSide(color: AppColors.goldGlow.withValues(alpha: 0.5)),
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              }),
                              IconButton(
                                icon: const Icon(Icons.share, color: AppColors.goldPrimary, size: 22),
                                tooltip: context.tr('fav_create_post'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AyahPostGeneratorScreen(
                                        surahNumber: fav.surahNumber,
                                        surahName: fav.surahName,
                                        ayahNumber: fav.ayahNumber,
                                        textAr: fav.textAr,
                                        textTr: fav.textTr,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                tooltip: context.tr('fav_remove'),
                                onPressed: () async {
                                  await quranProvider.toggleFavorite(
                                    surahNumber: fav.surahNumber,
                                    surahName: fav.surahName,
                                    ayahNumber: fav.ayahNumber,
                                    textAr: fav.textAr,
                                    textTr: fav.textTr,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.tr('fav_removed_snack'),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                        ),
                                        backgroundColor: AppColors.bgDark3,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: const BorderSide(color: AppColors.glassBorder),
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      if (fav.textAr.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          fav.textAr,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 24,
                            height: 1.9,
                            color: AppColors.textArabic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                      Text(
                        fav.textTr,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Divider(color: AppColors.glassBorder, height: 1),
                      const SizedBox(height: 8),

                      // Card Bottom Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            icon: const Icon(Icons.menu_book, color: AppColors.emeraldAccent, size: 18),
                            label: Text(
                              context.tr('fav_read_surah'),
                              style: const TextStyle(color: AppColors.emeraldAccent, fontSize: 13),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuranDetailScreen(
                                    surahNumber: fav.surahNumber,
                                    initialAyahIndex: fav.ayahNumber - 1,
                                  ),
                                ),
                              );
                            },
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emeraldDark,
                              foregroundColor: AppColors.goldGlow,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: const BorderSide(color: AppColors.goldPrimary, width: 0.8),
                            ),
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            label: Text(
                              context.tr('fav_create_post'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AyahPostGeneratorScreen(
                                    surahNumber: fav.surahNumber,
                                    surahName: fav.surahName,
                                    ayahNumber: fav.ayahNumber,
                                    textAr: fav.textAr,
                                    textTr: fav.textTr,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
