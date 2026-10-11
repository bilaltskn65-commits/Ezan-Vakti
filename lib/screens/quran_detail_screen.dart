import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quran_provider.dart';
import '../core/constants/app_colors.dart';
import 'hafiz_select_modal.dart';

class QuranDetailScreen extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahIndex;

  const QuranDetailScreen({
    super.key,
    required this.surahNumber,
    this.initialAyahIndex,
  });

  @override
  State<QuranDetailScreen> createState() => _QuranDetailScreenState();
}

class _QuranDetailScreenState extends State<QuranDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quranProvider = Provider.of<QuranProvider>(context, listen: false);
      quranProvider.loadSurah(widget.surahNumber, autoPlayAyahIndex: widget.initialAyahIndex);
    });
  }

  void _scrollToAyah(int index) {
    if (_scrollController.hasClients) {
      final targetOffset = index * 160.0;
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = Provider.of<QuranProvider>(context);
    final surah = quranProvider.currentSurah;

    if (quranProvider.isPlaying && quranProvider.currentAyahIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(quranProvider.currentAyahIndex);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark1,
      appBar: AppBar(
        title: Text(
          surah?.nameTr ?? 'Sure ${widget.surahNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over, color: AppColors.goldPrimary),
            tooltip: 'Hafız Seçimi',
            onPressed: () => HafizSelectModal.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: quranProvider.isLoadingAyahs
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.goldPrimary),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: quranProvider.ayahs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.bgDark3, AppColors.emeraldDark],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                surah?.nameAr ?? '',
                                style: GoogleFonts.scheherazadeNew(
                                  fontSize: 32,
                                  color: AppColors.goldGlow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${surah?.nameTr} • ${surah?.numberOfAyahs} Ayet • ${surah?.revelationTypeTr}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const Divider(color: AppColors.glassBorder, height: 24),
                              if (widget.surahNumber != 9)
                                Text(
                                  'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                  style: GoogleFonts.scheherazadeNew(
                                    fontSize: 24,
                                    color: AppColors.textArabic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        );
                      }

                      final ayahIndex = index - 1;
                      final ayah = quranProvider.ayahs[ayahIndex];
                      final isCurrentPlaying = (quranProvider.currentAyahIndex == ayahIndex);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCurrentPlaying
                              ? AppColors.emeraldDark.withValues(alpha: 0.5)
                              : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrentPlaying
                                ? AppColors.goldGlow
                                : AppColors.glassBorder,
                            width: isCurrentPlaying ? 2.0 : 1.0,
                          ),
                          boxShadow: isCurrentPlaying
                              ? [
                                  BoxShadow(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDark1,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.goldPrimary),
                                  ),
                                  child: Text(
                                    'Ayet ${ayah.numberInSurah}',
                                    style: const TextStyle(
                                      color: AppColors.goldPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isCurrentPlaying && quranProvider.isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    color: isCurrentPlaying
                                        ? AppColors.goldGlow
                                        : AppColors.emeraldAccent,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    if (isCurrentPlaying && quranProvider.isPlaying) {
                                      quranProvider.pauseAudio();
                                    } else {
                                      quranProvider.playAyah(ayahIndex);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ayah.textAr,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.scheherazadeNew(
                                fontSize: 26,
                                height: 2.0,
                                color: isCurrentPlaying
                                    ? AppColors.goldGlow
                                    : AppColors.textArabic,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ayah.textTr,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: isCurrentPlaying
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.bgDark3,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(top: BorderSide(color: AppColors.goldPrimary, width: 1)),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => HafizSelectModal.show(context),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.goldPrimary,
                        radius: 18,
                        child: Icon(Icons.person, color: AppColors.bgDark1, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quranProvider.selectedHafiz.nameTr,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            quranProvider.currentAyahIndex != -1
                                ? 'Ayet ${quranProvider.currentAyahIndex + 1} okunuyor'
                                : 'Hafız değiştir',
                            style: const TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: AppColors.textPrimary),
                  onPressed: () {
                    if (quranProvider.currentAyahIndex > 0) {
                      quranProvider.playAyah(quranProvider.currentAyahIndex - 1);
                    }
                  },
                ),
                CircleAvatar(
                  backgroundColor: AppColors.goldPrimary,
                  radius: 22,
                  child: IconButton(
                    icon: Icon(
                      quranProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.bgDark1,
                    ),
                    onPressed: () {
                      if (quranProvider.isPlaying) {
                        quranProvider.pauseAudio();
                      } else {
                        if (quranProvider.currentAyahIndex != -1) {
                          quranProvider.resumeAudio();
                        } else {
                          quranProvider.playAyah(0);
                        }
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: AppColors.textPrimary),
                  onPressed: () {
                    if (quranProvider.currentAyahIndex + 1 < quranProvider.ayahs.length) {
                      quranProvider.playAyah(quranProvider.currentAyahIndex + 1);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

