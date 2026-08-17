import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Profil bilgi kartındaki her bir satırı gösterir.
///
/// Solda ikon, yanında etiket ve değer içerir.
///
/// Örnek:
/// ```dart
/// ProfileInfoRow(
///   icon: Icons.school_outlined,
///   label: 'Üniversite',
///   value: 'İstanbul Teknik Üniversitesi',
/// )
/// ```
class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  /// Satır ikonu.
  final IconData icon;

  /// Etiket metni (alan adı).
  final String label;

  /// Değer metni.
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── İkon ──
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryIndigo.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primaryIndigo,
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // ── Etiket + Değer ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
