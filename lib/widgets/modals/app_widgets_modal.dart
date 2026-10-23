import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/locale_provider.dart';

class AppWidgetsModal extends StatelessWidget {
  const AppWidgetsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AppWidgetsModal(),
    );
  }

  static const _channel = MethodChannel('com.ezanvakti.app/widget');

  Future<void> _pinWidget(BuildContext context, String type, String title, LocaleProvider loc) async {
    try {
      final success = await _channel.invokeMethod<bool>('pinWidget', {'type': type});
      if (context.mounted) {
        if (success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                loc.translate('widget_pinned_snack', params: {'title': title}),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              backgroundColor: AppColors.bgDark3,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.emeraldAccent),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                loc.translate('widget_manual_snack', params: {'title': title}),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              backgroundColor: AppColors.bgDark3,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.glassBorder),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.translate('widget_help_snack'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppColors.bgDark3,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.glassBorder),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDark2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.goldPrimary, width: 1.5)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              const Icon(Icons.widgets, color: AppColors.goldPrimary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.translate('widgets_modal_title'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            loc.translate('widgets_modal_sub'),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Widget 1: Ezan Vakitleri
          _buildWidgetCard(
            context,
            icon: Icons.access_time_filled,
            iconColor: AppColors.goldPrimary,
            title: loc.translate('widget_prayer_title'),
            description: loc.translate('widget_prayer_desc'),
            buttonText: loc.translate('add'),
            onAdd: () => _pinWidget(context, 'prayer', loc.translate('widget_prayer_title'), loc),
          ),

          const SizedBox(height: 12),

          // Widget 2: Kuran Dinleme
          _buildWidgetCard(
            context,
            icon: Icons.headphones,
            iconColor: AppColors.emeraldAccent,
            title: loc.translate('widget_quran_title'),
            description: loc.translate('widget_quran_desc'),
            buttonText: loc.translate('add'),
            onAdd: () => _pinWidget(context, 'quran', loc.translate('widget_quran_title'), loc),
          ),

          const SizedBox(height: 12),

          // Widget 3: Sabitlenen Ayet
          _buildWidgetCard(
            context,
            icon: Icons.push_pin,
            iconColor: AppColors.goldGlow,
            title: loc.translate('widget_ayah_title'),
            description: loc.translate('widget_ayah_desc'),
            buttonText: loc.translate('add'),
            onAdd: () => _pinWidget(context, 'ayah', loc.translate('widget_ayah_title'), loc),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgDark3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emeraldPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
