import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quran_provider.dart';
import '../models/favorite_ayah_model.dart';
import '../core/constants/app_colors.dart';
import '../screens/ayah_post_generator_screen.dart';
import '../screens/quran_detail_screen.dart';

class HomePinnedAyahWidget extends StatelessWidget {
  const HomePinnedAyahWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final quran = Provider.of<QuranProvider>(context);
    final pinned = quran.pinnedAyah;

    if (pinned == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.push_pin_outlined, color: AppColors.goldPrimary, size: 28),
            const SizedBox(height: 8),
            const Text(
              'Sabitlenen Ayet Yok',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kuran bölümünden dilediğiniz bir ayeti ana ekrana sabitleyebilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                quran.pinAyah(
                  FavoriteAyahModel(
                    surahNumber: 94,
                    surahName: 'İnşirah',
                    ayahNumber: 5,
                    textAr: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
                    textTr: 'Şüphesiz her güçlükle beraber bir kolaylık vardır.',
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgDark3,
                foregroundColor: AppColors.goldGlow,
                side: const BorderSide(color: AppColors.goldPrimary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.push_pin, size: 16),
              label: const Text('Günün Ayetini Sabitle (İnşirah, 5)'),
            ),
          ],
        ),
      );
    }

    final isCurrentlyPlayingThis = quran.isPlaying &&
        quran.currentSurah?.number == pinned.surahNumber &&
        quran.currentPlayingAyah?.numberInSurah == pinned.ayahNumber;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.cardBg,
            AppColors.bgDark3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: 0.12),
            blurRadius: 14,
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
              // Badge & Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.push_pin,
                      color: AppColors.goldGlow,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sabitlenen Ayet',
                    style: TextStyle(
                      color: AppColors.goldGlow,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // Surah & Ayah Badge + Unpin button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark1,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      '${pinned.surahName} • ${pinned.ayahNumber}. Ayet',
                      style: const TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                    tooltip: 'Sabitlemeyi Kaldır',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          backgroundColor: AppColors.cardBg,
                          title: const Text('Sabitlemeyi Kaldır', style: TextStyle(color: AppColors.textPrimary)),
                          content: const Text(
                            'Bu ayeti ana ekrandan kaldırmak istiyor musunuz?',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dCtx),
                              child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(dCtx);
                                await quran.unpinAyah();
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              child: const Text('Kaldır', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Arabic Text
          if (pinned.textAr.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgDark1.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                pinned.textAr,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.notoNaskhArabic(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.9,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Turkish Translation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '"${pinned.textTr}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons: Dinle, Post Yap, Oku
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Dinle / Oynat Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isCurrentlyPlayingThis) {
                        quran.pauseAudio();
                      } else {
                        quran.playPinnedAyahAudio();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentlyPlayingThis
                          ? AppColors.emeraldDark
                          : AppColors.bgDark1,
                      foregroundColor: isCurrentlyPlayingThis
                          ? AppColors.emeraldAccent
                          : AppColors.goldPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(
                        color: isCurrentlyPlayingThis
                            ? AppColors.emeraldAccent
                            : AppColors.goldPrimary.withValues(alpha: 0.6),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      isCurrentlyPlayingThis ? Icons.pause : Icons.volume_up_rounded,
                      size: 16,
                    ),
                    label: Text(
                      isCurrentlyPlayingThis ? 'Durdur' : 'Dinle',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // Post / Görsel Yap Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AyahPostGeneratorScreen(
                            surahNumber: pinned.surahNumber,
                            surahName: pinned.surahName,
                            ayahNumber: pinned.ayahNumber,
                            textAr: pinned.textAr,
                            textTr: pinned.textTr,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bgDark1,
                      foregroundColor: AppColors.goldLight,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: AppColors.goldLight.withValues(alpha: 0.6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text(
                      'Post Yap',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // Sureye Git Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuranDetailScreen(
                            surahNumber: pinned.surahNumber,
                            initialAyahIndex: pinned.ayahNumber - 1,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bgDark1,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.glassBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.menu_book, size: 16),
                    label: const Text(
                      'Sureyi Aç',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
