import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Ders bilgilerini listeleyen kart widget'ı.
///
/// Alanlar:
/// - [courseCode]: Ders kodu (örn. CS101)
/// - [courseName]: Ders adı (örn. Bilgisayar Mühendisliğine Giriş)
/// - [departmentName]: Bölüm adı (örn. Bilgisayar Mühendisliği)
/// - [materialCount]: Materyal sayısı placeholder değeri (örn. 5)
/// - [onTap]: Karta tıklandığında çalışacak opsiyonel geri çağırma
class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.courseCode,
    required this.courseName,
    required this.departmentName,
    this.materialCount = 0,
    this.onTap,
    super.key,
  });

  final String courseCode;
  final String courseName;
  final String departmentName;
  final int materialCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Satır: Ders Kodu & Materyal Sayısı Placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ders Kodu Rozeti
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      courseCode,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Materyal Sayısı Placeholder Rozeti
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$materialCount Materyal',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Ders Adı
              Text(
                courseName,
                style: AppTextStyles.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),

              // Bölüm Adı
              Row(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      departmentName,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
