import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Ders materyali yükleme formu için dosya seçme bileşeni.
///
/// Kullanıcı bu bileşen üzerinden galeriden veya kameradan
/// ders notu/çıkmış soru görseli seçebilir.
///
/// Dosya seçildiğinde dosya adı, boyutu ve kaldırma butonu gösterilir.
class MaterialFilePicker extends StatelessWidget {
  const MaterialFilePicker({
    super.key,
    required this.selectedFile,
    required this.onFileChanged,
    this.enabled = true,
  });

  /// Seçili dosya (seçim yapılmadıysa `null`).
  final XFile? selectedFile;

  /// Dosya seçildiğinde veya kaldırıldığında çağrılır.
  final ValueChanged<XFile?> onFileChanged;

  /// Alanın aktif/pasif durumu.
  final bool enabled;

  /// Dosya seçim kaynağını soran alt menüyü açar.
  Future<void> _showPickerOptions(BuildContext context) async {
    if (!enabled) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Dosya Yükle',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primaryIndigo,
                    ),
                  ),
                  title: const Text('Galeriden Seç'),
                  subtitle: const Text('Cihazınızdaki görseller arasından seçin'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickFromSource(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.background,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primaryIndigo,
                    ),
                  ),
                  title: const Text('Kamerayla Çek'),
                  subtitle: const Text('Ders notunun fotoğrafını çekin'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickFromSource(context, ImageSource.camera);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Belirtilen kaynaktan görsel seçer.
  Future<void> _pickFromSource(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (file != null) {
        onFileChanged(file);
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
      onTap: enabled ? () => _showPickerOptions(context) : null,
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
              'Ders notu fotoğrafı veya belgesi seçmek için dokunun',
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
  Widget _buildSelectedFileCard(BuildContext context, XFile file) {
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
            child: const Icon(
              Icons.insert_drive_file_outlined,
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
                FutureBuilder<int>(
                  future: file.length(),
                  builder: (context, snapshot) {
                    final sizeText = snapshot.hasData
                        ? _formatFileSize(snapshot.data!)
                        : 'Hesaplanıyor...';
                    return Text(
                      sizeText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
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
