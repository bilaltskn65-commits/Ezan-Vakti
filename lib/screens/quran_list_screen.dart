import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quran_provider.dart';
import '../core/constants/app_colors.dart';
import 'quran_detail_screen.dart';
import 'hafiz_select_modal.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final quranProvider = Provider.of<QuranProvider>(context);
    final selectedHafiz = quranProvider.selectedHafiz;

    final filteredSurahs = quranProvider.surahList.where((surah) {
      final query = _searchQuery.toLowerCase();
      return surah.nameTr.toLowerCase().contains(query) ||
          surah.nameAr.contains(query) ||
          surah.number.toString() == query;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark1,
      appBar: AppBar(
        title: const Text(
          'Kuran-ı Kerim',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over, color: AppColors.goldPrimary),
            tooltip: 'Hafız Seç',
            onPressed: () => HafizSelectModal.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selected Hafiz Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.bgDark3, AppColors.emeraldDark],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.goldPrimary,
                    radius: 20,
                    child: Icon(Icons.record_voice_over, color: AppColors.bgDark1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Okuyan Hafız: ${selectedHafiz.nameTr}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          selectedHafiz.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => HafizSelectModal.show(context),
                    child: const Text(
                      'Değiştir',
                      style: TextStyle(color: AppColors.goldGlow, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bookmark Resume Card (Son Kaldığım Yer)
          if (quranProvider.lastSurahNumber != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranDetailScreen(
                        surahNumber: quranProvider.lastSurahNumber!,
                        initialAyahIndex: (quranProvider.lastAyahNumber ?? 1) - 1,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldDark.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.emeraldAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_added, color: AppColors.goldGlow, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kaldığın Yerden Devam Et',
                              style: TextStyle(
                                color: AppColors.goldGlow,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${quranProvider.lastSurahName ?? "Sure"} • ${quranProvider.lastAyahNumber}. Ayet',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_circle_fill, color: AppColors.goldGlow, size: 30),
                    ],
                  ),
                ),
              ),
            ),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Sure ara (Örn: Yasin, Fatiha, 36)...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.goldPrimary),
                filled: true,
                fillColor: AppColors.cardBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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

          // Surah List
          Expanded(
            child: quranProvider.isLoadingSurahs
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.goldPrimary),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredSurahs.length,
                    itemBuilder: (context, index) {
                      final surah = filteredSurahs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.bgDark3,
                            child: Text(
                              '${surah.number}',
                              style: const TextStyle(
                                color: AppColors.goldPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            surah.nameTr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${surah.numberOfAyahs} Ayet • ${surah.revelationTypeTr}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            surah.nameAr,
                            style: GoogleFonts.scheherazadeNew(
                              color: AppColors.goldGlow,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuranDetailScreen(surahNumber: surah.number),
                              ),
                            );
                          },
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

