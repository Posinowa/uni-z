import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Profil tamamlama formundaki bölüm başlıklarını gösterir.
///
/// Örnek:
/// ```dart
/// ProfileFormSection(title: 'Eğitim Bilgileri')
/// ```
class ProfileFormSection extends StatelessWidget {
  const ProfileFormSection({
    required this.title,
    super.key,
  });

  /// Bölüm başlığı metni.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.primaryIndigo,
          ),
        ),
      ],
    );
  }
}
