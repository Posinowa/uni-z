import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Etkinlik detay ekranında tarih, saat, konum ve organizatör bilgilerini
/// düzenli ve temaya uygun bir biçimde gösteren bilgi kartı/satırı bileşeni.
///
/// Uzun metinlerde yatay taşmayı önlemek için [Expanded] yapısı kullanır.
class EventDetailInfoTile extends StatelessWidget {
  /// Bilgi başlığı (örn: 'Tarih', 'Saat', 'Konum', 'Organizatör').
  final String label;

  /// Gösterilecek değer metni.
  final String value;

  /// Sol tarafta gösterilecek simge.
  final IconData icon;

  /// Simge rengi. Varsayılan olarak [AppColors.categoryEvents] kullanılır.
  final Color iconColor;

  const EventDetailInfoTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.categoryEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── İkon Kutucuğu ─────────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderRadiusSm,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // ─── Etiket ve Değer ───────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
