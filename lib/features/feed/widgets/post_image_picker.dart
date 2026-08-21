import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Gönderi oluşturma ekranında galeriden görsel seçme ve önizleme widget'ı.
///
/// Görsel seçilmediğinde "Fotoğraf Ekle" butonu gösterir.
/// Görsel seçildiğinde önizleme ve sağ üstte kaldırma butonu (`Icons.close`) sunar.
class PostImagePicker extends StatelessWidget {
  /// Şu an seçili olan görsel dosyası (`null` ise seçili görsel yoktur).
  final XFile? selectedImage;

  /// Görsel seçildiğinde veya kaldırıldığında çağrılacak fonksiyon.
  final ValueChanged<XFile?> onImageChanged;

  /// Bileşenin tıklanabilir olup olmadığı (`false` ise işlem yapılamaz).
  final bool enabled;

  /// Test edilebilirlik için opsiyonel [ImagePicker] nesnesi.
  final ImagePicker? imagePicker;

  const PostImagePicker({
    required this.selectedImage,
    required this.onImageChanged,
    this.enabled = true,
    this.imagePicker,
    super.key,
  });

  Future<void> _pickImage(BuildContext context) async {
    if (!enabled) return;

    final picker = imagePicker ?? ImagePicker();

    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        onImageChanged(image);
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Galeriye erişilirken izin hatası oluştu: ${e.message ?? e.code}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görsel seçilirken bir hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedImage == null) {
      return _buildPickerButton(context);
    }

    return _buildImagePreview(context, selectedImage!);
  }

  Widget _buildPickerButton(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _pickImage(context) : null,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primaryIndigo,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Görsel Ekle',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryIndigo,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, XFile image) {
    return Stack(
      children: [
        // Görsel Önizleme Alanı
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: double.infinity,
            height: 220,
            color: AppColors.surface,
            child: FutureBuilder<Uint8List>(
              future: image.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.error,
                          size: 40,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Görsel yüklenemedi',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 220,
                );
              },
            ),
          ),
        ),

        // Görsel Kaldırma Butonu (Sağ Üst)
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Material(
            color: Colors.black.withValues(alpha: 0.6),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? () => onImageChanged(null) : null,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.xs + 2),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
