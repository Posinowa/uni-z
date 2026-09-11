import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Ders detay ekranının üst kısmında ders bilgilerini gösteren kart bileşeni.
///
/// Gösterilen bilgiler:
/// - Ders kodu (Vurgulu rozet olarak)
/// - Ders adı
/// - Üniversite ve bölüm bilgisi
/// - Ders açıklaması (mevcut değilse varsayılan bilgilendirme metni)
class CourseInfoCard extends StatelessWidget {
  const CourseInfoCard({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.universityName,
    required this.departmentName,
    this.description,
  });

  final String courseCode;
  final String courseName;
  final String universityName;
  final String departmentName;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final hasDescription = description != null && description!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ders Kodu Rozeti ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: AppColors.primaryIndigo.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tag,
                      size: 14,
                      color: AppColors.primaryIndigo,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      courseCode,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Ders Adı ──
          Text(
            courseName,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Üniversite ve Bölüm ──
          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '$universityName • $departmentName',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.md),

          // ── Açıklama Başlığı & Metni ──
          Text(
            'Ders Açıklaması',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasDescription
                ? description!
                : 'Bu ders için henüz bir açıklama eklenmemiş.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: hasDescription
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontStyle:
                  hasDescription ? FontStyle.normal : FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
