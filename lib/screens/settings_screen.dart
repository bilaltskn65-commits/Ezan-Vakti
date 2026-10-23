import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/constants/app_colors.dart';
import '../core/services/notification_service.dart';
import '../providers/prayer_provider.dart';
import '../providers/quran_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/modals/notification_test_modal.dart';
import '../widgets/modals/location_search_modal.dart';
import '../widgets/modals/hafiz_select_modal.dart';
import '../widgets/modals/meal_select_modal.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notifEnabled = await NotificationService.areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = notifEnabled;
      });
    }
  }

  Future<void> _setLanguage(String langCode) async {
    final loc = context.read<LocaleProvider>();
    await loc.setLanguage(langCode);
    if (!mounted) return;
    final prayerTimes = context.read<PrayerProvider>().prayerTimes;
    if (prayerTimes != null) {
      // Arka plan alarmlarını seçilen yeni dilde anında tekrar kur
      await NotificationService.schedulePrayerNotifications(prayerTimes);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.interpolate('lang_selected_snack', {'lang': loc.languageName})),
        backgroundColor: AppColors.emeraldPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSoundSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _SoundSelectionModal(),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showEzanSoundSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _EzanSoundSelectionModal(),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showLanguageDialog(BuildContext context) {
    final loc = context.read<LocaleProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgDark2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.language, color: AppColors.goldGlow, size: 22),
            const SizedBox(width: 10),
            Text(
              loc.translate('lang_dialog_title'),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangRadio(context, 'Türkçe (TR)', 'tr'),
            _buildLangRadio(context, 'English (EN)', 'en'),
            _buildLangRadio(context, 'العربية (AR)', 'ar'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.translate('close'),
              style: const TextStyle(color: AppColors.goldGlow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangRadio(BuildContext context, String title, String code) {
    final currentCode = context.watch<LocaleProvider>().languageCode;
    final isSelected = currentCode == code;

    return InkWell(
      onTap: () {
        _setLanguage(code);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.emeraldAccent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.emeraldAccent : Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.emeraldAccent : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.emeraldAccent, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerProvider>();
    final quranProvider = context.watch<QuranProvider>();
    final loc = context.watch<LocaleProvider>();
    final currentSoundKey = NotificationService.countdownSoundName;
    final soundInfo = NotificationService.availableCountdownSounds[currentSoundKey];
    final currentEzanKey = NotificationService.prayerEntrySoundName;
    final ezanSoundInfo = NotificationService.availablePrayerEntrySounds[currentEzanKey];

    return Scaffold(
      backgroundColor: AppColors.bgDark1,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark2,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('settings_title'),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              loc.translate('settings_subtitle'),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= 1. BİLDİRİMLER VE SESLER =================
            _buildSectionHeader(loc.translate('sec_notifications'), Icons.notifications_active_outlined),
            _buildCard(
              children: [
                _buildSettingTile(
                  icon: Icons.music_note,
                  iconColor: AppColors.goldGlow,
                  title: loc.translate('sound_tile_title'),
                  subtitle: soundInfo?.title ?? 'Seçilen Ses',
                  trailingText: loc.translate('change'),
                  onTap: () => _showSoundSelectionBottomSheet(context),
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildSettingTile(
                  icon: Icons.volume_up_outlined,
                  iconColor: AppColors.emeraldAccent,
                  title: loc.translate('ezan_tile_title'),
                  subtitle: ezanSoundInfo?.title ?? 'Mişari Raşid - Ezan Tekbiri',
                  trailingText: loc.translate('change'),
                  onTap: () => _showEzanSoundSelectionBottomSheet(context),
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildSettingTile(
                  icon: Icons.speed,
                  iconColor: Colors.amberAccent,
                  title: loc.translate('test_tile_title'),
                  subtitle: loc.translate('test_tile_sub'),
                  trailingText: loc.translate('test'),
                  onTap: () => NotificationTestModal.show(context),
                ),
                if (!_notificationsEnabled) ...[
                  const Divider(color: Colors.white10, height: 1),
                  _buildSettingTile(
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.redAccent,
                    title: loc.translate('perm_tile_title'),
                    subtitle: loc.translate('perm_tile_sub'),
                    trailingText: loc.translate('allow'),
                    onTap: () async {
                      await NotificationService.requestPermissions();
                      await _loadSettings();
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // ================= 2. KONUM VE VAKİT =================
            _buildSectionHeader(loc.translate('sec_location'), Icons.location_on_outlined),
            _buildCard(
              children: [
                _buildSettingTile(
                  icon: Icons.my_location,
                  iconColor: AppColors.goldPrimary,
                  title: loc.translate('location_tile_title'),
                  subtitle: prayerProvider.locationName,
                  trailingText: loc.translate('change'),
                  onTap: () => LocationSearchModal.show(context),
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildSettingTile(
                  icon: Icons.mosque_outlined,
                  iconColor: AppColors.emeraldAccent,
                  title: loc.translate('method_tile_title'),
                  subtitle: loc.translate('method_tile_sub'),
                  trailingText: null,
                  onTap: null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ================= 3. KUR'AN VE OKUMA TERCİHLERİ =================
            _buildSectionHeader(loc.translate('sec_quran'), Icons.menu_book_outlined),
            _buildCard(
              children: [
                _buildSettingTile(
                  icon: Icons.record_voice_over_outlined,
                  iconColor: AppColors.goldGlow,
                  title: loc.translate('hafiz_tile_title'),
                  subtitle: quranProvider.selectedHafiz.nameTr,
                  trailingText: loc.translate('select'),
                  onTap: () => HafizSelectModal.show(context),
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildSettingTile(
                  icon: Icons.translate,
                  iconColor: AppColors.emeraldAccent,
                  title: loc.translate('meal_tile_title'),
                  subtitle: '${quranProvider.currentTranslation.name} (${quranProvider.currentTranslation.author})',
                  trailingText: loc.translate('select'),
                  onTap: () => MealSelectModal.show(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ================= 4. GENEL TERCİHLER =================
            _buildSectionHeader(loc.translate('sec_general'), Icons.tune),
            _buildCard(
              children: [
                _buildSettingTile(
                  icon: Icons.language,
                  iconColor: Colors.lightBlueAccent,
                  title: loc.translate('lang_tile_title'),
                  subtitle: loc.languageName,
                  trailingText: loc.translate('change'),
                  onTap: () => _showLanguageDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ================= 5. HAKKINDA =================
            _buildSectionHeader(loc.translate('sec_about'), Icons.info_outline),
            _buildCard(
              children: [
                _buildSettingTile(
                  icon: Icons.verified_outlined,
                  iconColor: AppColors.goldGlow,
                  title: loc.translate('about_app_name'),
                  subtitle: loc.translate('about_version'),
                  trailingText: null,
                  onTap: null,
                ),
                const Divider(color: Colors.white10, height: 1),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.emeraldAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          loc.translate('about_privacy'),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String? trailingText,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailingText,
                      style: const TextStyle(
                        color: AppColors.goldGlow,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: AppColors.goldGlow, size: 14),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 45 Dakika Bildirim Sesini Dinleme ve Seçme Modalı
class _SoundSelectionModal extends StatefulWidget {
  const _SoundSelectionModal();

  @override
  State<_SoundSelectionModal> createState() => _SoundSelectionModalState();
}

class _SoundSelectionModalState extends State<_SoundSelectionModal> {
  AudioPlayer? _player;
  String? _playingKey;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String key, String fileName) async {
    try {
      _player ??= AudioPlayer();
      await _player!.stop();
      setState(() => _playingKey = key);
      await _player!.play(AssetSource('audio/$fileName'));
      _player!.onPlayerComplete.listen((_) {
        if (mounted && _playingKey == key) {
          setState(() => _playingKey = null);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _playingKey = null);
    }
  }

  Future<void> _stopAudio() async {
    await _player?.stop();
    if (mounted) setState(() => _playingKey = null);
  }

  @override
  Widget build(BuildContext context) {
    final sounds = NotificationService.availableCountdownSounds;
    final activeKey = NotificationService.countdownSoundName;
    final loc = context.watch<LocaleProvider>();
    final maxModalHeight = MediaQuery.of(context).size.height * 0.78;

    return Container(
      constraints: BoxConstraints(maxHeight: maxModalHeight),
      decoration: const BoxDecoration(
        color: AppColors.bgDark2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1.5)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 18,
        right: 18,
        top: 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.music_note, color: AppColors.goldGlow, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('sound_modal_title'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      loc.translate('sound_modal_sub'),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: sounds.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = sounds.entries.elementAt(index);
                final key = entry.key;
                final isSelected = activeKey == key;
                final isPlaying = _playingKey == key;

                return InkWell(
                  onTap: () async {
                    // Kullanıcı tıkladığı an sesi duysun ve bildirim sesi yapılsın
                    await NotificationService.setCountdownSound(key);
                    await _playAudio(key, entry.value.fileName);
                    setState(() {});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.interpolate('sound_selected_snack', {'sound': entry.value.title})),
                          backgroundColor: AppColors.emeraldPrimary,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.emeraldAccent.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.emeraldAccent.withValues(alpha: 0.6) : Colors.white10,
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                            color: isPlaying ? Colors.amberAccent : AppColors.goldGlow,
                            size: 32,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (isPlaying) {
                              _stopAudio();
                            } else {
                              _playAudio(key, entry.value.fileName);
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value.title,
                                style: TextStyle(
                                  color: isSelected ? AppColors.emeraldAccent : AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.value.desc,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await NotificationService.setCountdownSound(key);
                            await _playAudio(key, entry.value.fileName);
                            setState(() {});
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(loc.interpolate('sound_selected_snack', {'sound': entry.value.title})),
                                  backgroundColor: AppColors.emeraldPrimary,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? AppColors.emeraldPrimary : Colors.white12,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isSelected ? '✓ ${loc.translate('active')}' : loc.translate('select'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
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

/// Namaz Vakti (Ezan) Bildirim Sesini Dinleme ve Seçme Modalı
class _EzanSoundSelectionModal extends StatefulWidget {
  const _EzanSoundSelectionModal();

  @override
  State<_EzanSoundSelectionModal> createState() => _EzanSoundSelectionModalState();
}

class _EzanSoundSelectionModalState extends State<_EzanSoundSelectionModal> {
  AudioPlayer? _player;
  String? _playingKey;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String key, String fileName) async {
    try {
      _player ??= AudioPlayer();
      await _player!.stop();
      setState(() => _playingKey = key);
      await _player!.play(AssetSource('audio/$fileName'));
      _player!.onPlayerComplete.listen((_) {
        if (mounted && _playingKey == key) {
          setState(() => _playingKey = null);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _playingKey = null);
    }
  }

  Future<void> _stopAudio() async {
    await _player?.stop();
    if (mounted) setState(() => _playingKey = null);
  }

  @override
  Widget build(BuildContext context) {
    final sounds = NotificationService.availablePrayerEntrySounds;
    final activeKey = NotificationService.prayerEntrySoundName;
    final loc = context.watch<LocaleProvider>();
    final maxModalHeight = MediaQuery.of(context).size.height * 0.78;

    return Container(
      constraints: BoxConstraints(maxHeight: maxModalHeight),
      decoration: const BoxDecoration(
        color: AppColors.bgDark2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1.5)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 18,
        right: 18,
        top: 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emeraldAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up_outlined, color: AppColors.emeraldAccent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('ezan_modal_title'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      loc.translate('ezan_modal_sub'),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: sounds.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = sounds.entries.elementAt(index);
                final key = entry.key;
                final isSelected = activeKey == key;
                final isPlaying = _playingKey == key;

                return InkWell(
                  onTap: () async {
                    // Kullanıcı tıkladığı an sesi duysun ve ezan sesi yapılsın
                    await NotificationService.setPrayerEntrySound(key);
                    await _playAudio(key, entry.value.fileName);
                    setState(() {});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.interpolate('ezan_selected_snack', {'sound': entry.value.title})),
                          backgroundColor: AppColors.emeraldPrimary,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.emeraldAccent.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.emeraldAccent.withValues(alpha: 0.6) : Colors.white10,
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                            color: isPlaying ? Colors.amberAccent : AppColors.goldGlow,
                            size: 32,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (isPlaying) {
                              _stopAudio();
                            } else {
                              _playAudio(key, entry.value.fileName);
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value.title,
                                style: TextStyle(
                                  color: isSelected ? AppColors.emeraldAccent : AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.value.desc,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await NotificationService.setPrayerEntrySound(key);
                            await _playAudio(key, entry.value.fileName);
                            setState(() {});
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(loc.interpolate('ezan_selected_snack', {'sound': entry.value.title})),
                                  backgroundColor: AppColors.emeraldPrimary,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? AppColors.emeraldPrimary : Colors.white12,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isSelected ? '✓ ${loc.translate('active')}' : loc.translate('select'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
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
