import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/asma_data.dart';
import '../core/localization/localization_extension.dart';
import '../models/asma_model.dart';

class AsmaScreen extends StatefulWidget {
  const AsmaScreen({super.key});

  @override
  State<AsmaScreen> createState() => _AsmaScreenState();
}

class _AsmaScreenState extends State<AsmaScreen> {
  String _searchQuery = '';
  bool _isGridView = false;

  void _showDetailModal(AsmaModel asma) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AsmaDetailModal(asma: asma),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = AsmaData.search(_searchQuery, lang: context.langCode);

    return Scaffold(
      backgroundColor: AppColors.bgDark1,
      appBar: AppBar(
        title: Text(
          context.tr('asma_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors.goldPrimary,
            ),
            tooltip: _isGridView ? context.tr('asma_tooltip_list') : context.tr('asma_tooltip_grid'),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: context.tr('asma_search_hint'),
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.goldPrimary),
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

          // Count info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('asma_total_count', {'count': '${filtered.length}'}),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  context.tr('asma_tap_hint'),
                  style: const TextStyle(color: AppColors.goldLight, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Content List or Grid
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('asma_not_found', {'query': _searchQuery}),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.05,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final asma = filtered[index];
                          return InkWell(
                            onTap: () => _showDetailModal(asma),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.bgDark3,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${asma.id}',
                                          style: const TextStyle(
                                            color: AppColors.goldLight,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${asma.ebced}x',
                                        style: const TextStyle(
                                          color: AppColors.emeraldAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    asma.nameAr,
                                    style: GoogleFonts.scheherazadeNew(
                                      fontSize: 22,
                                      color: AppColors.goldGlow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (context.langCode != 'ar') ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      asma.getLocalizedName(context.langCode),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const Spacer(),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final asma = filtered[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.glassBorder,
                              ),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              leading: Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.bgDark3, AppColors.emeraldDark],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.6),
                                  ),
                                ),
                                child: Text(
                                  '${asma.id}',
                                  style: const TextStyle(
                                    color: AppColors.goldGlow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      asma.getLocalizedName(context.langCode),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (context.langCode != 'ar')
                                    Text(
                                      asma.nameAr,
                                      style: GoogleFonts.scheherazadeNew(
                                        fontSize: 22,
                                        color: AppColors.goldGlow,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  asma.getLocalizedMeaning(context.langCode),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                  textAlign: context.isArabic ? TextAlign.right : TextAlign.left,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.bgDark1,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.emeraldAccent.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  '${asma.ebced}x',
                                  style: const TextStyle(
                                    color: AppColors.emeraldAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              onTap: () => _showDetailModal(asma),
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

// Interactive Detail & Zikirmatik BottomSheet
class _AsmaDetailModal extends StatefulWidget {
  final AsmaModel asma;

  const _AsmaDetailModal({required this.asma});

  @override
  State<_AsmaDetailModal> createState() => _AsmaDetailModalState();
}

class _AsmaDetailModalState extends State<_AsmaDetailModal> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
    HapticFeedback.lightImpact();
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
    HapticFeedback.mediumImpact();
  }

  void _copy() {
    final lang = context.langCode;
    Clipboard.setData(
      ClipboardData(
        text: '${widget.asma.getLocalizedName(lang)} (${widget.asma.nameAr})\n'
            '${context.tr('asma_meaning')}: ${widget.asma.getLocalizedMeaning(lang)}\n'
            '${context.tr('asma_virtue')}: ${widget.asma.getLocalizedVirtue(lang)}\n'
            'Ebced: ${widget.asma.ebced}',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.emeraldAccent, size: 20),
            const SizedBox(width: 10),
            Text(
              context.tr('asma_copied_snack'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final asma = widget.asma;
    final progress = (asma.ebced > 0) ? (_counter / asma.ebced).clamp(0.0, 1.0) : 0.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.bgDark1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.goldPrimary, width: 1.5)),
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
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark3,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.goldPrimary),
                  ),
                  child: Text(
                    context.tr('asma_item_number', {'id': '${asma.id}'}),
                    style: const TextStyle(
                      color: AppColors.goldGlow,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.goldPrimary),
                  tooltip: context.tr('copy'),
                  onPressed: _copy,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  // Calligraphy Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.bgDark3, AppColors.emeraldDark],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withValues(alpha: 0.15),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          asma.nameAr,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 42,
                            color: AppColors.goldGlow,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (context.langCode != 'ar') ...[
                          const SizedBox(height: 6),
                          Text(
                            asma.getLocalizedName(context.langCode),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Meaning Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          context.isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Row(
                          textDirection:
                              context.isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            const Icon(Icons.menu_book, color: AppColors.emeraldAccent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('asma_meaning'),
                              style: const TextStyle(
                                color: AppColors.emeraldAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          asma.getLocalizedMeaning(context.langCode),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: context.isArabic ? TextAlign.right : TextAlign.left,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Virtue Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          context.isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Row(
                          textDirection:
                              context.isArabic ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.goldLight, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('asma_virtue'),
                              style: const TextStyle(
                                color: AppColors.goldLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          asma.getLocalizedVirtue(context.langCode),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                          textAlign: context.isArabic ? TextAlign.right : TextAlign.left,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Interactive Zikirmatik Ring
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.tr('asma_dhikr_ring'),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.bgDark3,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.tr('asma_target', {'ebced': '${asma.ebced}'}),
                                style: const TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Circular Tap Button
                        GestureDetector(
                          onTap: _increment,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 8,
                                  backgroundColor: AppColors.bgDark3,
                                  color: progress >= 1.0
                                      ? AppColors.emeraldAccent
                                      : AppColors.goldPrimary,
                                ),
                              ),
                              Container(
                                width: 114,
                                height: 114,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [AppColors.bgDark3, AppColors.cardBg],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.goldPrimary.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$_counter',
                                      style: const TextStyle(
                                        color: AppColors.goldGlow,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      context.tr('asma_tap'),
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        if (_counter > 0)
                          TextButton.icon(
                            icon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 16),
                            label: Text(
                              context.tr('asma_reset'),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            onPressed: _reset,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
