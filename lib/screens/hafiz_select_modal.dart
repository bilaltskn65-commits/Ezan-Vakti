import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hafiz_model.dart';
import '../providers/quran_provider.dart';
import '../core/constants/app_colors.dart';

class HafizSelectModal extends StatelessWidget {
  const HafizSelectModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HafizSelectModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = Provider.of<QuranProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.bgDark1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.goldPrimary, width: 1.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.record_voice_over, color: AppColors.goldPrimary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Hafız Seçimi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Kuran-ı Kerim sesli okunuşu için 10 dünyaca ünlü hafız',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.glassBorder, height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: HafizList.reciters.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final hafiz = HafizList.reciters[index];
                final isSelected = (quranProvider.selectedHafiz.id == hafiz.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.emeraldDark.withValues(alpha: 0.4)
                        : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.goldPrimary : AppColors.glassBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? AppColors.goldPrimary : AppColors.bgDark3,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isSelected ? AppColors.bgDark1 : AppColors.goldPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      hafiz.nameTr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hafiz.nameAr,
                          style: const TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 14,
                            fontFamily: 'Scheherazade',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hafiz.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.goldGlow, size: 28)
                        : const Icon(Icons.play_circle_outline, color: AppColors.textSecondary),
                    onTap: () {
                      quranProvider.selectHafiz(hafiz);
                      Navigator.pop(context);
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

