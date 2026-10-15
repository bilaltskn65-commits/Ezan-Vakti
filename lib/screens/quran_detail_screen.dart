import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../providers/quran_provider.dart';
import '../core/constants/app_colors.dart';
import 'hafiz_select_modal.dart';
import 'ayah_post_generator_screen.dart';
import 'favorite_ayahs_screen.dart';
import '../models/favorite_ayah_model.dart';

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
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quickAyahController = TextEditingController();
  bool _isSearchOpen = false;
  int? _highlightedAyahIndex;
  int _lastAutoScrolledAyah = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quranProvider = Provider.of<QuranProvider>(context, listen: false);
      quranProvider.loadSurah(widget.surahNumber, autoPlayAyahIndex: widget.initialAyahIndex).then((_) {
        if (widget.initialAyahIndex != null && mounted) {
          _jumpToAyah(widget.initialAyahIndex!);
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quickAyahController.dispose();
    super.dispose();
  }

  void _scrollToAyah(int index) {
    if (!_itemScrollController.isAttached) return;
    final targetIndex = (!_isSearchOpen || _searchController.text.trim().isEmpty)
        ? (index + 2)
        : index;
    try {
      _itemScrollController.scrollTo(
        index: targetIndex,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
      );
    } catch (_) {}
  }

  void _jumpToAyah(int ayahIndex) {
    if (ayahIndex < 0) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _highlightedAyahIndex = ayahIndex;
      _isSearchOpen = false;
      _searchController.clear();
    });

    void performScroll() {
      if (!mounted) return;
      if (_itemScrollController.isAttached) {
        try {
          _itemScrollController.scrollTo(
            index: ayahIndex + 2,
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeInOutCubic,
            alignment: 0.05,
          );
        } catch (_) {}
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      performScroll();
      Future.delayed(const Duration(milliseconds: 120), performScroll);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _highlightedAyahIndex = null;
        });
      }
    });
  }

  void _showJumpToAyahModal(BuildContext context, QuranProvider quranProvider) {
    final totalAyahs = quranProvider.ayahs.length;
    if (totalAyahs == 0) return;

    int selectedNumber = 1;
    final textController = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
              decoration: const BoxDecoration(
                color: AppColors.bgDark2,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: AppColors.goldPrimary, width: 1.5)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.goldPrimary,
                          radius: 18,
                          child: Icon(Icons.tag_rounded, color: AppColors.bgDark1, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${quranProvider.currentSurah?.nameTr ?? "Sure"} Suresi',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Toplam $totalAyahs Ayet • Hızlı Ayet Seçimi',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Number Input & Quick Go Button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: AppColors.goldGlow,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'Ayet No (1 - $totalAyahs)',
                              labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              prefixIcon: const Icon(Icons.numbers, color: AppColors.goldPrimary),
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
                            onChanged: (val) {
                              final parsed = int.tryParse(val);
                              if (parsed != null && parsed >= 1 && parsed <= totalAyahs) {
                                setModalState(() {
                                  selectedNumber = parsed;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldPrimary,
                            foregroundColor: AppColors.bgDark1,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('GİT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          onPressed: () {
                            final parsed = int.tryParse(textController.text.trim()) ?? selectedNumber;
                            final validNum = parsed.clamp(1, totalAyahs);
                            Navigator.pop(ctx);
                            _jumpToAyah(validNum - 1);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Slider for fast navigation
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.goldPrimary,
                        inactiveTrackColor: AppColors.glassBorder,
                        thumbColor: AppColors.goldGlow,
                        overlayColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        min: 1,
                        max: totalAyahs.toDouble(),
                        value: selectedNumber.toDouble().clamp(1.0, totalAyahs.toDouble()),
                        divisions: totalAyahs > 1 ? totalAyahs - 1 : 1,
                        label: '$selectedNumber. Ayet',
                        onChanged: (val) {
                          setModalState(() {
                            selectedNumber = val.round();
                            textController.text = '$selectedNumber';
                          });
                        },
                      ),
                    ),

                    // Landmark shortcut chips
                    const SizedBox(height: 6),
                    const Text(
                      'Hızlı Atlama Noktaları:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickChip('İlk Ayet (1)', () {
                          Navigator.pop(ctx);
                          _jumpToAyah(0);
                        }),
                        if (widget.surahNumber == 2) ...[
                          _buildQuickChip('Ayetel Kürsi (255)', () {
                            Navigator.pop(ctx);
                            _jumpToAyah(254);
                          }),
                          _buildQuickChip('Âmenerresûlü (285)', () {
                            Navigator.pop(ctx);
                            _jumpToAyah(284);
                          }),
                        ],
                        if (widget.surahNumber == 36) ...[
                          _buildQuickChip('Selâm Ayeti (58)', () {
                            Navigator.pop(ctx);
                            _jumpToAyah(57);
                          }),
                        ],
                        if (totalAyahs > 20)
                          _buildQuickChip('Orta Ayet (${(totalAyahs / 2).round()})', () {
                            Navigator.pop(ctx);
                            _jumpToAyah((totalAyahs / 2).round() - 1);
                          }),
                        _buildQuickChip('Son Ayet ($totalAyahs)', () {
                          Navigator.pop(ctx);
                          _jumpToAyah(totalAyahs - 1);
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onQuickJumpSubmitted(String val, int totalAyahs) {
    final parsed = int.tryParse(val.trim());
    if (parsed != null && parsed >= 1 && parsed <= totalAyahs) {
      _quickAyahController.clear();
      FocusScope.of(context).unfocus();
      _jumpToAyah(parsed - 1);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen 1 ile $totalAyahs arasında geçerli bir ayet numarası girin.'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _buildQuickJumpBar(BuildContext context, QuranProvider quranProvider) {
    final totalAyahs = quranProvider.ayahs.length;
    if (totalAyahs <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.goldGlow, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Ayet Numarası ile Çabuk Arama / Git',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '1 - $totalAyahs Ayet',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.bgDark1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: TextField(
                    controller: _quickAyahController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: AppColors.goldGlow,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.tag, color: AppColors.goldPrimary, size: 18),
                      hintText: 'Ayet No yazın (1 - $totalAyahs)...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) {
                      _onQuickJumpSubmitted(val, totalAyahs);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: AppColors.bgDark1,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Git', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () {
                  _onQuickJumpSubmitted(_quickAyahController.text, totalAyahs);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Landmark shortcut chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickJumpChip('1. Ayet', () => _jumpToAyah(0)),
                const SizedBox(width: 6),
                if (widget.surahNumber == 2) ...[
                  _buildQuickJumpChip('Ayetel Kürsi (255)', () => _jumpToAyah(254)),
                  const SizedBox(width: 6),
                  _buildQuickJumpChip('Âmenerresûlü (285)', () => _jumpToAyah(284)),
                  const SizedBox(width: 6),
                ],
                if (widget.surahNumber == 36) ...[
                  _buildQuickJumpChip('Selâm Ayeti (58)', () => _jumpToAyah(57)),
                  const SizedBox(width: 6),
                ],
                if (widget.surahNumber == 3) ...[
                  _buildQuickJumpChip('18. Ayet (Şehidallâh)', () => _jumpToAyah(17)),
                  const SizedBox(width: 6),
                ],
                if (totalAyahs > 20) ...[
                  _buildQuickJumpChip('Orta (${(totalAyahs / 2).round()})', () => _jumpToAyah((totalAyahs / 2).round() - 1)),
                  const SizedBox(width: 6),
                ],
                _buildQuickJumpChip('Son ($totalAyahs)', () => _jumpToAyah(totalAyahs - 1)),
                const SizedBox(width: 6),
                ActionChip(
                  avatar: const Icon(Icons.tune_rounded, size: 13, color: AppColors.goldPrimary),
                  label: const Text('Kaydırıcı & Detaylı Seçici', style: TextStyle(fontSize: 11, color: AppColors.goldGlow)),
                  backgroundColor: AppColors.bgDark1,
                  side: const BorderSide(color: AppColors.goldPrimary, width: 0.8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onPressed: () => _showJumpToAyahModal(context, quranProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickJumpChip(String label, VoidCallback onTap) {
    return ActionChip(
      avatar: const Icon(Icons.bolt, size: 13, color: AppColors.goldGlow),
      label: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
      backgroundColor: AppColors.bgDark1,
      side: const BorderSide(color: AppColors.glassBorder),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: onTap,
    );
  }

  Widget _buildSurahHeaderCard(dynamic surah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bgDark3, AppColors.emeraldDark],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.5),
        ),
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

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return ActionChip(
      avatar: const Icon(Icons.flash_on, size: 14, color: AppColors.goldGlow),
      label: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
      backgroundColor: AppColors.cardBg,
      side: const BorderSide(color: AppColors.glassBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = Provider.of<QuranProvider>(context);
    final surah = quranProvider.currentSurah;

    // Show audio feedback toast if any
    if (quranProvider.audioFeedbackMessage != null) {
      final msg = quranProvider.audioFeedbackMessage!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              duration: const Duration(seconds: 3),
              backgroundColor: AppColors.bgDark3,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          quranProvider.clearAudioFeedback();
        }
      });
    }

    if (quranProvider.isPlaying &&
        quranProvider.currentAyahIndex != -1 &&
        quranProvider.currentAyahIndex != _lastAutoScrolledAyah) {
      _lastAutoScrolledAyah = quranProvider.currentAyahIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(quranProvider.currentAyahIndex);
      });
    } else if (!quranProvider.isPlaying) {
      _lastAutoScrolledAyah = -1;
    }

    final searchQuery = _searchController.text.trim().toLowerCase();
    final numSearch = int.tryParse(searchQuery);

    final filteredAyahs = quranProvider.ayahs.where((ayah) {
      if (searchQuery.isEmpty) return true;
      if (numSearch != null) {
        return ayah.numberInSurah == numSearch;
      }
      return ayah.textTr.toLowerCase().contains(searchQuery) ||
             ayah.textAr.contains(searchQuery) ||
             ayah.numberInSurah.toString() == searchQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark1,
      appBar: AppBar(
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ayet No (1 - ${quranProvider.ayahs.length}) veya metin...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (val) {
                  final parsed = int.tryParse(val.trim());
                  if (parsed != null && parsed >= 1 && parsed <= quranProvider.ayahs.length) {
                    _jumpToAyah(parsed - 1);
                  }
                },
              )
            : Text(
                surah?.nameTr ?? 'Sure ${widget.surahNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
        actions: [
          // Clear Ayet Selector badge in AppBar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ActionChip(
              avatar: const Icon(Icons.tag, color: AppColors.goldPrimary, size: 14),
              label: Text(
                quranProvider.ayahs.isNotEmpty
                    ? '${(quranProvider.currentAyahIndex != -1 ? (quranProvider.currentAyahIndex + 1) : 1)}/${quranProvider.ayahs.length}'
                    : 'Ayet Seç',
                style: const TextStyle(
                  color: AppColors.goldGlow,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor: AppColors.cardBg,
              side: const BorderSide(color: AppColors.goldPrimary, width: 0.8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onPressed: () => _showJumpToAyahModal(context, quranProvider),
            ),
          ),
          IconButton(
            icon: Icon(_isSearchOpen ? Icons.close : Icons.search, color: AppColors.goldPrimary),
            tooltip: _isSearchOpen ? 'Aramayı Kapat' : 'Ayet / Metin Ara',
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: AppColors.goldPrimary),
            tooltip: 'Beğenilen Ayetler',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoriteAyahsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.record_voice_over, color: AppColors.goldPrimary),
            tooltip: 'Hafız Seçimi',
            onPressed: () => HafizSelectModal.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchOpen && searchQuery.isNotEmpty && numSearch != null && numSearch >= 1 && numSearch <= quranProvider.ayahs.length)
            Container(
              width: double.infinity,
              color: AppColors.bgDark3,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '$numSearch. Ayet bulundu',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.goldGlow),
                    icon: const Icon(Icons.navigation, size: 16),
                    label: const Text('Bu Ayete Git'),
                    onPressed: () => _jumpToAyah(numSearch - 1),
                  ),
                ],
              ),
            ),
          Expanded(
            child: quranProvider.isLoadingAyahs
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.goldPrimary),
                  )
                : quranProvider.ayahs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.menu_book_outlined, color: AppColors.goldPrimary, size: 54),
                              const SizedBox(height: 16),
                              Text(
                                quranProvider.errorMessage.isNotEmpty
                                    ? quranProvider.errorMessage
                                    : 'Ayetler yüklenemedi',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.goldPrimary,
                                  foregroundColor: AppColors.bgDark1,
                                ),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Tekrar Dene'),
                                onPressed: () {
                                  quranProvider.loadSurah(widget.surahNumber);
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredAyahs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, color: AppColors.goldPrimary, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  '"$searchQuery" ile eşleşen ayet bulunamadı',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: (!_isSearchOpen || searchQuery.isEmpty)
                        ? (filteredAyahs.length + 2)
                        : filteredAyahs.length,
                    itemBuilder: (context, index) {
                      if (!_isSearchOpen || searchQuery.isEmpty) {
                        if (index == 0) {
                          return _buildSurahHeaderCard(surah);
                        }
                        if (index == 1) {
                          return _buildQuickJumpBar(context, quranProvider);
                        }
                      }

                      final ayahIndex = (!_isSearchOpen || searchQuery.isEmpty) ? (index - 2) : index;
                      final ayah = filteredAyahs[ayahIndex];
                      final globalAyahIdx = ayah.numberInSurah - 1;
                      final isCurrentPlaying = (quranProvider.currentAyahIndex == globalAyahIdx);
                      final isHighlighted = (_highlightedAyahIndex == globalAyahIdx);

                      return Container(
                        key: ValueKey('ayah_$globalAyahIdx'),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isHighlighted
                              ? AppColors.goldPrimary.withValues(alpha: 0.15)
                              : (isCurrentPlaying
                                  ? AppColors.emeraldDark.withValues(alpha: 0.5)
                                  : AppColors.cardBg),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isHighlighted
                                ? AppColors.goldGlow
                                : (isCurrentPlaying
                                    ? AppColors.goldGlow
                                    : AppColors.glassBorder),
                            width: isHighlighted ? 2.5 : (isCurrentPlaying ? 2.0 : 1.0),
                          ),
                          boxShadow: isHighlighted || isCurrentPlaying
                              ? [
                                  BoxShadow(
                                    color: AppColors.goldPrimary.withValues(alpha: isHighlighted ? 0.4 : 0.25),
                                    blurRadius: isHighlighted ? 14 : 10,
                                    spreadRadius: isHighlighted ? 2 : 1,
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
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
                                    if (_isSearchOpen && searchQuery.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => _jumpToAyah(globalAyahIdx),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.goldPrimary.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: AppColors.goldPrimary, width: 0.8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.goldGlow),
                                              SizedBox(width: 4),
                                              Text(
                                                'Ayete Git',
                                                style: TextStyle(
                                                  color: AppColors.goldGlow,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Favorite Toggle Button
                                    IconButton(
                                      icon: Icon(
                                        quranProvider.isAyahFavorite(widget.surahNumber, ayah.numberInSurah)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: quranProvider.isAyahFavorite(widget.surahNumber, ayah.numberInSurah)
                                            ? Colors.redAccent
                                            : AppColors.textSecondary,
                                        size: 22,
                                      ),
                                      tooltip: 'Beğenilenlere Ekle',
                                      onPressed: () async {
                                        final added = await quranProvider.toggleFavorite(
                                          surahNumber: widget.surahNumber,
                                          surahName: surah?.nameTr ?? 'Sure ${widget.surahNumber}',
                                          ayahNumber: ayah.numberInSurah,
                                          textAr: ayah.textAr,
                                          textTr: ayah.textTr,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                added
                                                    ? '${ayah.numberInSurah}. Ayet beğenilenlere eklendi'
                                                    : '${ayah.numberInSurah}. Ayet beğenilenlerden çıkarıldı',
                                              ),
                                              backgroundColor: added ? AppColors.emeraldDark : AppColors.cardBg,
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    // Ana Ekran Widget'ına Sabitle Button (Tek ve Net)
                                    Builder(builder: (context) {
                                      final isPinned = quranProvider.isAyahPinned(
                                        widget.surahNumber,
                                        ayah.numberInSurah,
                                      );
                                      return IconButton(
                                        icon: Icon(
                                          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                          color: isPinned ? AppColors.goldGlow : AppColors.textSecondary,
                                          size: 22,
                                        ),
                                        tooltip: isPinned ? 'Widget Sabitlemesini Kaldır' : 'Ana Ekran Widget\'ına Sabitle',
                                        onPressed: () async {
                                          if (isPinned) {
                                            await quranProvider.unpinAyah();
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Ayet ana ekran widget\'ından kaldırıldı'),
                                                  duration: Duration(seconds: 1),
                                                ),
                                              );
                                            }
                                          } else {
                                            await quranProvider.pinAyah(
                                              FavoriteAyahModel(
                                                surahNumber: widget.surahNumber,
                                                surahName: surah?.nameTr ?? 'Sure ${widget.surahNumber}',
                                                ayahNumber: ayah.numberInSurah,
                                                textAr: ayah.textAr,
                                                textTr: ayah.textTr,
                                              ),
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '📌 ${surah?.nameTr ?? "Sure"} ${ayah.numberInSurah}. Ayet ana ekran widget\'ına sabitlendi!',
                                                  ),
                                                  backgroundColor: AppColors.emeraldDark,
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      );
                                    }),
                                    // Post Oluştur Button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.auto_awesome,
                                        color: AppColors.goldLight,
                                        size: 22,
                                      ),
                                      tooltip: 'Post / Kart Oluştur',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AyahPostGeneratorScreen(
                                              surahNumber: widget.surahNumber,
                                              surahName: surah?.nameTr ?? 'Sure ${widget.surahNumber}',
                                              ayahNumber: ayah.numberInSurah,
                                              textAr: ayah.textAr,
                                              textTr: ayah.textTr,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Audio Play / Pause
                                    IconButton(
                                      icon: Icon(
                                        isCurrentPlaying && quranProvider.isPlaying
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_fill,
                                        color: isCurrentPlaying
                                            ? AppColors.goldGlow
                                            : AppColors.emeraldAccent,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        if (isCurrentPlaying && quranProvider.isPlaying) {
                                          quranProvider.pauseAudio();
                                        } else {
                                          quranProvider.playAyah(globalAyahIdx);
                                        }
                                      },
                                    ),
                                  ],
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

