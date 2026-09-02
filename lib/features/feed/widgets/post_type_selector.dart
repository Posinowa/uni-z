import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/post_type.dart';

/// Post türü seçimi için yatay ChoiceChip listesi.
///
/// Kullanıcı Genel, Kampüs veya Duyuru seçeneklerinden birini seçer.
/// Seçim [onChanged] callback ile üst widget'a bildirilir.
class PostTypeSelector extends StatelessWidget {
  const PostTypeSelector({
    required this.selectedType,
    required this.onChanged,
    super.key,
  });

  /// Şu an seçili olan post türü.
  final PostType selectedType;

  /// Post türü değiştiğinde çağrılacak fonksiyon.
  final ValueChanged<PostType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Post Türü',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: PostType.values.map((type) {
            final isSelected = type == selectedType;
            return ChoiceChip(
              label: Text(_labelFor(type)),
              selected: isSelected,
              onSelected: (_) => onChanged(type),
              selectedColor: AppColors.primaryIndigo,
              backgroundColor: AppColors.surface,
              labelStyle: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color:
                      isSelected ? AppColors.primaryIndigo : AppColors.border,
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// PostType enum değerini kullanıcı dostu Türkçe etikete dönüştürür.
  String _labelFor(PostType type) {
    switch (type) {
      case PostType.general:
        return 'Genel';
      case PostType.campus:
        return 'Kampüs';
      case PostType.announcement:
        return 'Duyuru';
    }
  }
}
