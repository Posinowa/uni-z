import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Ders materyali yükleme formu için dosya seçme bileşeni.
///
/// Kullanıcı bu bileşen üzerinden cihazından PDF veya görsel dosyası
/// (jpg, jpeg, png) seçebilir.
///
/// Dosya seçildiğinde dosya adı, boyutu ve kaldırma butonu gösterilir.
/// Desteklenmeyen dosya tipleri [FilePicker] tarafından filtrelenir.
class MaterialFilePicker extends StatelessWidget {
  const MaterialFilePicker({
    super.key,
    required this.selectedFile,
    required this.onFileChanged,
    this.enabled = true,
  });

  /// Seçili dosya (seçim yapılmadıysa `null`).
  final PlatformFile? selectedFile;

  /// Dosya seçildiğinde veya kaldırıldığında çağrılır.
  final ValueChanged<PlatformFile?> onFileChanged;

  /// Alanın aktif/pasif durumu.
  final bool enabled;

  /// İzin verilen dosya uzantıları.
  static const List<String> _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  /// Cihazdan dosya seçer. Yalnızca izin verilen tipler gösterilir.
  Future<void> _pickFile(BuildContext context) async {
    if (!enabled) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        onFileChanged(result.files.first);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosya seçilirken bir hata oluştu.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Dosya boyutunu okunabilir biçime çevirir (KB / MB).
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Dosya uzantısına göre uygun ikon döner.
  IconData _fileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    if (selectedFile != null) {
      return _buildSelectedFileCard(context, selectedFile!);
    }

    return _buildEmptyState(context);
  }

  /// Henüz dosya seçilmemişken gösterilen seçim alanı.
  Widget _buildEmptyState(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _pickFile(context) : null,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.primaryIndigo.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: AppColors.primaryIndigo,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Dosya Seç',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryIndigo,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'PDF, JPG, JPEG veya PNG seçmek için dokunun',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Dosya seçildikten sonra gösterilen bilgi kartı.
  Widget _buildSelectedFileCard(BuildContext context, PlatformFile file) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              _fileIcon(file.extension),
              color: AppColors.primaryIndigo,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (file.size > 0)
                  Text(
                    _formatFileSize(file.size),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
            tooltip: 'Dosyayı Kaldır',
            onPressed: enabled ? () => onFileChanged(null) : null,
          ),
        ],
      ),
    );
  }
}
