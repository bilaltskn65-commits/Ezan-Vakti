import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/quran_service.dart';
import '../../providers/quran_provider.dart';
import '../../providers/locale_provider.dart';

class MealSelectModal extends StatefulWidget {
  const MealSelectModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MealSelectModal(),
    );
  }

  @override
  State<MealSelectModal> createState() => _MealSelectModalState();
}

class _MealSelectModalState extends State<MealSelectModal> {
  late String _selectedLanguageCode;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final quranProvider = Provider.of<QuranProvider>(context, listen: false);
      final currentMeal = QuranTranslations.getById(quranProvider.selectedTranslation);
      _selectedLanguageCode = currentMeal.languageCode;
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = Provider.of<QuranProvider>(context);
    final loc = context.watch<LocaleProvider>();
    final availableMeals = QuranTranslations.getByLanguage(_selectedLanguageCode);

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.bgDark1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.goldPrimary, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.translate, color: AppColors.goldPrimary, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('meal_modal_title'),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        loc.translate('meal_modal_sub'),
                        style: const TextStyle(
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

          const SizedBox(height: 14),

          // Language Selection Chips
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: QuranTranslations.languages.length,
              itemBuilder: (context, index) {
                final lang = QuranTranslations.languages[index];
                final isSelected = (lang.code == _selectedLanguageCode);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: isSelected,
                    showCheckmark: false,
                    label: Text('${lang.flag} ${lang.name}'),
                    selectedColor: AppColors.goldPrimary,
                    backgroundColor: AppColors.cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.goldPrimary : AppColors.glassBorder,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.bgDark1 : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedLanguageCode = lang.code;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(color: AppColors.glassBorder, height: 24),

          // Meals List in Selected Language
          Expanded(
            child: availableMeals.isEmpty
                ? const Center(
                    child: Text(
                      'Bu dilde meal bulunamadı.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: availableMeals.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemBuilder: (context, index) {
                      final meal = availableMeals[index];
                      final isSelected = (quranProvider.selectedTranslation == meal.id);

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
                            child: Icon(
                              Icons.menu_book,
                              color: isSelected ? AppColors.bgDark1 : AppColors.goldLight,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  meal.name,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.goldGlow : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (meal.id == 'tr.diyanet') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                                  ),
                                  child: const Text(
                                    'Dahili Çevrimdışı',
                                    style: TextStyle(
                                      color: AppColors.goldLight,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                meal.author,
                                style: const TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                meal.description,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.goldGlow, size: 26)
                              : const Icon(Icons.radio_button_unchecked, color: AppColors.textSecondary, size: 22),
                          onTap: () {
                            quranProvider.selectTranslation(meal.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: AppColors.emeraldAccent, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '${meal.name} seçildi',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: AppColors.bgDark3,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AppColors.glassBorder),
                                ),
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
