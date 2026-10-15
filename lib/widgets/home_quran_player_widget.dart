import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../core/constants/app_colors.dart';
import '../screens/hafiz_select_modal.dart';
import '../screens/quran_detail_screen.dart';

class HomeQuranPlayerWidget extends StatefulWidget {
  const HomeQuranPlayerWidget({super.key});

  @override
  State<HomeQuranPlayerWidget> createState() => _HomeQuranPlayerWidgetState();
}

class _HomeQuranPlayerWidgetState extends State<HomeQuranPlayerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quran = Provider.of<QuranProvider>(context);
    final isPlaying = quran.isPlaying;

    // Track display information
    final trackTitle = quran.activeTrackTitle;
    final hafizName = quran.selectedHafiz.nameTr;
    final activeSurahNumber = quran.currentSurah?.number ??
        quran.pinnedAyah?.surahNumber ??
        quran.lastSurahNumber ??
        1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPlaying
              ? AppColors.goldGlow.withValues(alpha: 0.8)
              : AppColors.glassBorder,
          width: isPlaying ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isPlaying)
            BoxShadow(
              color: AppColors.goldPrimary.withValues(alpha: 0.2),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
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
              // Icon + Header Title + Status Pill
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? AppColors.emeraldAccent.withValues(alpha: 0.2)
                          : AppColors.bgDark3,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.graphic_eq : Icons.headphones,
                      color: isPlaying ? AppColors.emeraldAccent : AppColors.goldPrimary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kuran Dinle',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isPlaying)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.emeraldAccent),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, color: AppColors.emeraldAccent, size: 10),
                          SizedBox(width: 3),
                          Text(
                            'Çalıyor',
                            style: TextStyle(
                              color: AppColors.emeraldAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Hafiz Selector Chip
              InkWell(
                onTap: () => HafizSelectModal.show(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mic, color: AppColors.goldPrimary, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        hafizName,
                        style: const TextStyle(
                          color: AppColors.goldGlow,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, color: AppColors.goldPrimary, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Track Info & Equalizer row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgDark1.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trackTitle,
                        style: const TextStyle(
                          color: AppColors.goldGlow,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPlaying
                            ? 'Şimdi okunuyor • $hafizName'
                            : 'Dinlemek için oynat butonuna basın',
                        style: TextStyle(
                          color: isPlaying
                              ? AppColors.emeraldAccent
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPlaying) ...[
                  const SizedBox(width: 8),
                  _buildAnimatedEqualizer(),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Audio Controls Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Go to Surah Button
              IconButton(
                icon: const Icon(Icons.menu_book_rounded, color: AppColors.goldPrimary, size: 24),
                tooltip: 'Sureyi Aç',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranDetailScreen(surahNumber: activeSurahNumber),
                    ),
                  );
                },
              ),

              // Previous Ayah Button
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 28),
                tooltip: 'Önceki Ayet',
                onPressed: () => quran.playPreviousAyah(),
              ),

              // Big Center Play/Pause Button
              GestureDetector(
                onTap: () => quran.quickTogglePlayFromHome(),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.goldPrimary, AppColors.goldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withValues(alpha: isPlaying ? 0.6 : 0.3),
                        blurRadius: isPlaying ? 16 : 8,
                        spreadRadius: isPlaying ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: AppColors.bgDark1,
                      size: 32,
                    ),
                  ),
                ),
              ),

              // Next Ayah Button
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 28),
                tooltip: 'Sonraki Ayet',
                onPressed: () => quran.playNextAyah(),
              ),

              // Stop Audio Button
              IconButton(
                icon: const Icon(Icons.stop_rounded, color: AppColors.textSecondary, size: 24),
                tooltip: 'Durdur',
                onPressed: isPlaying ? () => quran.stopAudio() : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedEqualizer() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final v = _animController.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _bar(8 + (v * 14)),
            const SizedBox(width: 3),
            _bar(20 - (v * 12)),
            const SizedBox(width: 3),
            _bar(12 + (v * 10)),
            const SizedBox(width: 3),
            _bar(18 - (v * 14)),
          ],
        );
      },
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 3.5,
      height: height.clamp(4.0, 22.0),
      decoration: BoxDecoration(
        color: AppColors.emeraldAccent,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
