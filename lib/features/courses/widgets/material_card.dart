import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Onaylanmış bir ders materyalini listede gösteren kart bileşeni.
///
/// Gösterilen bilgiler:
/// - Dosya tipine göre ikon (pdf / görsel / diğer)
/// - Başlık
/// - Materyal tipi (Türkçe etiket)
/// - Yüklenme tarihi
/// - Dosya uzantısı rozeti
/// - Rapor butonu (tıklanabilir, aksiyon ayrı issue'da gelecek)
class MaterialCard extends StatelessWidget {
  const MaterialCard({
    super.key,
    required this.title,
    required this.type,
    required this.fileType,
    required this.createdAt,
    required this.onReportTap,
  });

  /// Materyal başlığı.
  final String title;

  /// Firestore type değeri: lecture_note, past_exam, summary, other.
  final String type;

  /// Dosya uzantısı: pdf, jpg, png vb.
  final String fileType;

  /// Yüklenme zamanı (Firestore Timestamp).
  final Timestamp? createdAt;

  /// Rapor butonuna basıldığında tetiklenecek fonksiyon.
  final VoidCallback onReportTap;

  /// Firestore type değerini Türkçe etikete çevirir.
  String _typeLabel(String type) {
    switch (type) {
      case 'lecture_note':
        return 'Ders Notu';
      case 'past_exam':
        return 'Çıkmış Soru';
      case 'summary':
        return 'Özet';
      default:
        return 'Diğer';
    }
  }

  /// Dosya uzantısına göre uygun ikon döner.
  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  /// Timestamp'i okunabilir tarih metnine çevirir.
  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dosya Tipi İkonu ──
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              _fileIcon(fileType),
              color: AppColors.primaryIndigo,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // ── Başlık, Tip, Tarih ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    // Tip etiketi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        _typeLabel(type),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryIndigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Dosya uzantısı rozeti
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        fileType.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                // Yüklenme tarihi
                if (createdAt != null)
                  Text(
                    _formatDate(createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // ── Rapor Butonu ──
          IconButton(
            icon: const Icon(Icons.flag_outlined, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Raporla',
            onPressed: onReportTap,
          ),
        ],
      ),
    );
  }
}
