import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/states/app_empty_state.dart';

/// Ders detay ekranındaki "Materyaller" sekmesini temsil eden widget.
///
/// Junior geliştiriciler için:
/// Bu sekmede ders notları, çıkmış sorular ve özetler gibi materyal kategorileri
/// filtre çipleri ile listelenir. Henüz gerçek listeleme bu issue kapsamında olmadığı için
/// bilgilendirici bir [AppEmptyState] ve doğrudan bir "Materyal Yükle" aksiyon butonu gösterilir.
class CourseMaterialsTab extends StatefulWidget {
  const CourseMaterialsTab({
    super.key,
    required this.onUploadPressed,
  });

  /// Materyal yükle butonuna basıldığında tetiklenecek fonksiyon.
  final VoidCallback onUploadPressed;

  @override
  State<CourseMaterialsTab> createState() => _CourseMaterialsTabState();
}

class _CourseMaterialsTabState extends State<CourseMaterialsTab> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    'Tümü',
    'Ders Notları',
    'Çıkmış Sorular',
    'Özetler',
    'Diğer',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Kategori Filtre Çipleri ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(_filters[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilterIndex = index);
                      }
                    },
                    selectedColor: AppColors.primaryIndigo,
                    backgroundColor: AppColors.surface,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryIndigo
                            : AppColors.border,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Boş Durum (Empty State) ──
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xxl,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                AppEmptyState(
                  title: 'Henüz materyal bulunmuyor',
                  description:
                      'Bu ders için ilk ders notunu, çıkmış soruyu veya özeti sen yükleyerek arkadaşlarına destek ol!',
                  icon: Icons.folder_open_outlined,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Materyal Yükle Butonu ──
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: PrimaryButton(
                    text: 'Materyal Yükle',
                    icon: Icons.upload_file_outlined,
                    onPressed: widget.onUploadPressed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Bilgilendirici İpucu Notu ──
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.primaryIndigo.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.primaryIndigo,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Yüklenen materyaller telif ve içerik kontrollerinin ardından yayınlanır.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
