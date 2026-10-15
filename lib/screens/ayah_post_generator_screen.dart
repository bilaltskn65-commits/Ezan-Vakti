import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../core/constants/app_colors.dart';

class AyahPostTheme {
  final String name;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color arabicColor;
  final Color translationColor;
  final Color badgeBg;
  final Color badgeTextColor;

  const AyahPostTheme({
    required this.name,
    required this.gradientColors,
    required this.borderColor,
    required this.arabicColor,
    required this.translationColor,
    required this.badgeBg,
    required this.badgeTextColor,
  });
}

class AyahPostGeneratorScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String textAr;
  final String textTr;

  const AyahPostGeneratorScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.textAr,
    required this.textTr,
  });

  @override
  State<AyahPostGeneratorScreen> createState() => _AyahPostGeneratorScreenState();
}

class _AyahPostGeneratorScreenState extends State<AyahPostGeneratorScreen> {
  final GlobalKey _previewKey = GlobalKey();

  // Themes
  final List<AyahPostTheme> _themes = const [
    AyahPostTheme(
      name: 'Zümrüt & Altın',
      gradientColors: [Color(0xFF042F2E), Color(0xFF064E3B), Color(0xFF0F172A)],
      borderColor: Color(0xFFF59E0B),
      arabicColor: Color(0xFFFFEAA7),
      translationColor: Color(0xFFF1F5F9),
      badgeBg: Color(0xFFD97706),
      badgeTextColor: Color(0xFF0F172A),
    ),
    AyahPostTheme(
      name: 'Kabe & İpek',
      gradientColors: [Color(0xFF090D16), Color(0xFF1E1E24), Color(0xFF0A0A0A)],
      borderColor: Color(0xFFFFD700),
      arabicColor: Color(0xFFFFD700),
      translationColor: Color(0xFFE2E8F0),
      badgeBg: Color(0xFFFFD700),
      badgeTextColor: Color(0xFF000000),
    ),
    AyahPostTheme(
      name: 'Gece & Hilal',
      gradientColors: [Color(0xFF0B192C), Color(0xFF1E3E62), Color(0xFF000000)],
      borderColor: Color(0xFF38BDF8),
      arabicColor: Color(0xFFE0F2FE),
      translationColor: Color(0xFFF8FAFC),
      badgeBg: Color(0xFF0284C7),
      badgeTextColor: Color(0xFFFFFFFF),
    ),
    AyahPostTheme(
      name: 'Gül & Yakut',
      gradientColors: [Color(0xFF4A0404), Color(0xFF2C0B0E), Color(0xFF120002)],
      borderColor: Color(0xFFFBBF24),
      arabicColor: Color(0xFFFEF3C7),
      translationColor: Color(0xFFFDF2F8),
      badgeBg: Color(0xFF991B1B),
      badgeTextColor: Color(0xFFFFFBEB),
    ),
    AyahPostTheme(
      name: 'Modern Antrasit',
      gradientColors: [Color(0xFF18181B), Color(0xFF27272A), Color(0xFF09090B)],
      borderColor: Color(0xFFA1A1AA),
      arabicColor: Color(0xFFFAFAFA),
      translationColor: Color(0xFFE4E4E7),
      badgeBg: Color(0xFF3F3F46),
      badgeTextColor: Color(0xFFFFFFFF),
    ),
  ];

  int _selectedThemeIndex = 0;
  bool _isStoryMode = false; // false = 1:1 Square, true = 9:16 Story
  bool _showArabic = true;
  bool _showBismillah = true;
  double _fontSizeScale = 1.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Auto-scale default font size for longer ayahs to ensure balanced look
    final totalLength = widget.textAr.length + widget.textTr.length;
    if (totalLength > 350) {
      _fontSizeScale = 0.75;
    } else if (totalLength > 180) {
      _fontSizeScale = 0.85;
    } else {
      _fontSizeScale = 1.0;
    }
  }

  String _buildShareCaption() {
    final buffer = StringBuffer();
    if (_showBismillah) {
      buffer.writeln('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\n');
    }
    if (_showArabic && widget.textAr.isNotEmpty) {
      buffer.writeln(widget.textAr);
      buffer.writeln();
    }
    buffer.writeln(widget.textTr);
    buffer.writeln();
    buffer.writeln('— ${widget.surahName} Suresi, ${widget.ayahNumber}. Ayet');
    buffer.writeln('#Kuran #Ayet #EzanVakti');
    return buffer.toString();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _buildShareCaption()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.copy, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Ayet ve meali panoya kopyalandı!'),
          ],
        ),
        backgroundColor: AppColors.emeraldAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<Uint8List?> _captureImageBytes() async {
    try {
      final boundary =
          _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  Future<void> _sharePost() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final bytes = await _captureImageBytes();
      if (bytes == null) {
        throw Exception('Görsel oluşturulamadı. Lütfen tekrar deneyiniz.');
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = 'EzanVakti_${widget.surahNumber}_${widget.ayahNumber}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      final caption = _buildShareCaption();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: caption,
          subject: '${widget.surahName} Suresi ${widget.ayahNumber}. Ayet',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım hatası: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final bytes = await _captureImageBytes();
      if (bytes == null) {
        throw Exception('Görsel oluşturulamadı.');
      }

      final safeSurah = widget.surahName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final imageName = 'EzanVakti_${safeSurah}_Ayet_${widget.ayahNumber}_${DateTime.now().millisecondsSinceEpoch}';

      await Gal.putImageBytes(
        bytes,
        name: imageName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Görsel telefonun galerisine başarıyla kaydedildi!'),
                ),
              ],
            ),
            backgroundColor: AppColors.emeraldAccent,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on GalException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Galeri izni veya kayıt hatası: ${e.type.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kaydetme hatası: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showPreviewModal() async {
    final bytes = await _captureImageBytes();
    if (bytes == null || !mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgDark1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.goldPrimary),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.emeraldAccent),
            SizedBox(width: 8),
            Text(
              'Ayet Kartı Hazır!',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                bytes,
                height: 220,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Görsel ultra HD kalitede hazırlandı. WhatsApp, Instagram, Telegram vb. uygulamalarda paylaşabilir veya galerinize indirebilirsiniz.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: AppColors.textSecondary)),
          ),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.goldPrimary),
                  foregroundColor: AppColors.goldGlow,
                ),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('İndir'),
                onPressed: () {
                  Navigator.pop(ctx);
                  _saveToGallery();
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldDark,
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text('Paylaş'),
                onPressed: () {
                  Navigator.pop(ctx);
                  _sharePost();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themes[_selectedThemeIndex];

    return Scaffold(
      backgroundColor: AppColors.bgDark1,
      appBar: AppBar(
        title: const Text(
          'Ayet Kartı / Post Oluştur',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.textPrimary),
            tooltip: 'Önizle',
            onPressed: _showPreviewModal,
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.goldGlow),
            tooltip: 'Galeriye İndir',
            onPressed: _isProcessing ? null : _saveToGallery,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.emeraldAccent),
            tooltip: 'WhatsApp / Instagram Paylaş',
            onPressed: _isProcessing ? null : _sharePost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Live Post Preview Card (RepaintBoundary)
            Center(
              child: RepaintBoundary(
                key: _previewKey,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isStoryMode ? 290 : 340,
                  height: _isStoryMode ? 515 : 340,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: theme.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.borderColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: theme.borderColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative corner pattern elements
                      Positioned(
                        top: 2,
                        left: 2,
                        child: Icon(Icons.flare, size: 16, color: theme.borderColor.withValues(alpha: 0.6)),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Icon(Icons.flare, size: 16, color: theme.borderColor.withValues(alpha: 0.6)),
                      ),
                      Positioned(
                        bottom: 2,
                        left: 2,
                        child: Icon(Icons.flare, size: 16, color: theme.borderColor.withValues(alpha: 0.6)),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Icon(Icons.flare, size: 16, color: theme.borderColor.withValues(alpha: 0.6)),
                      ),

                      // Content with FittedBox to guarantee ZERO overflow even on long ayahs
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: (_isStoryMode ? 290.0 : 340.0) - 52,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (_showBismillah) ...[
                                      Text(
                                        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                        style: GoogleFonts.scheherazadeNew(
                                          fontSize: 16 * _fontSizeScale,
                                          color: theme.borderColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                    ],

                                    if (_showArabic && widget.textAr.isNotEmpty) ...[
                                      Text(
                                        widget.textAr,
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.scheherazadeNew(
                                          fontSize: 19 * _fontSizeScale,
                                          height: 1.7,
                                          color: theme.arabicColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    Text(
                                      '"${widget.textTr}"',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13 * _fontSizeScale,
                                        height: 1.4,
                                        fontStyle: FontStyle.italic,
                                        color: theme.translationColor,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Reference Badge
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.badgeBg,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: theme.borderColor.withValues(alpha: 0.8)),
                                        ),
                                        child: Text(
                                          '${widget.surahName} • ${widget.ayahNumber}. Ayet',
                                          style: TextStyle(
                                            color: theme.badgeTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Theme Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    Icon(Icons.palette, color: AppColors.goldPrimary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Tema Seçimi',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _themes.length,
                itemBuilder: (context, index) {
                  final t = _themes[index];
                  final isSelected = _selectedThemeIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(t.name),
                      selectedColor: AppColors.goldPrimary,
                      backgroundColor: AppColors.cardBg,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.bgDark1 : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() {
                          _selectedThemeIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Controls & Toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  children: [
                    // Format Toggle: Post vs Story
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Boyut Formatı',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              label: Text('Kare 1:1'),
                              icon: Icon(Icons.crop_square, size: 16),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text('Hikaye 9:16'),
                              icon: Icon(Icons.stay_current_portrait, size: 16),
                            ),
                          ],
                          selected: {_isStoryMode},
                          onSelectionChanged: (set) {
                            setState(() {
                              _isStoryMode = set.first;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.goldPrimary;
                              }
                              return AppColors.bgDark3;
                            }),
                            foregroundColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.bgDark1;
                              }
                              return AppColors.textPrimary;
                            }),
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: AppColors.glassBorder, height: 24),

                    // Toggles
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Arapça Metni Göster', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      value: _showArabic,
                      activeTrackColor: AppColors.goldPrimary,
                      activeThumbColor: AppColors.goldLight,
                      onChanged: (val) => setState(() => _showArabic = val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Besmele Başlığı', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      value: _showBismillah,
                      activeTrackColor: AppColors.goldPrimary,
                      activeThumbColor: AppColors.goldLight,
                      onChanged: (val) => setState(() => _showBismillah = val),
                    ),

                    const Divider(color: AppColors.glassBorder, height: 16),

                    // Font Size Slider
                    Row(
                      children: [
                        const Text('Yazı Boyutu', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                        Expanded(
                          child: Slider(
                            value: _fontSizeScale.clamp(0.6, 1.3),
                            min: 0.6,
                            max: 1.3,
                            divisions: 7,
                            activeColor: AppColors.goldPrimary,
                            inactiveColor: AppColors.bgDark3,
                            onChanged: (val) => setState(() => _fontSizeScale = val),
                          ),
                        ),
                        Text(
                          '${(_fontSizeScale * 100).toInt()}%',
                          style: const TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Galeriye İndir Button
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.goldPrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.08),
                          ),
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.goldGlow),
                                )
                              : const Icon(Icons.download_rounded, color: AppColors.goldGlow),
                          label: const Text(
                            'Galeriye İndir',
                            style: TextStyle(color: AppColors.goldGlow, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          onPressed: _isProcessing ? null : _saveToGallery,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Postu Paylaş Button
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.emeraldDark,
                            side: const BorderSide(color: AppColors.emeraldAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.share_rounded, color: AppColors.textPrimary),
                          label: const Text(
                            'Postu Paylaş',
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          onPressed: _isProcessing ? null : _sharePost,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    icon: const Icon(Icons.copy, size: 16, color: AppColors.textSecondary),
                    label: const Text(
                      'Sadece Ayet Metnini Panoya Kopyala',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
