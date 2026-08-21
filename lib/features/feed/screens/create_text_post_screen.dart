import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../models/post_type.dart';
import '../widgets/post_image_picker.dart';

/// Gönderi oluşturma ekranı.
///
/// Post türü seçimi, metin girişi ve galeriden görsel seçimi içerir.
/// R2 upload ve Firestore görsel kaydı bu issue kapsamında değildir.
class CreateTextPostScreen extends StatefulWidget {
  /// Gönderi oluşturulduğunda çağrılacak opsiyonel callback.
  final VoidCallback? onPostCreated;

  const CreateTextPostScreen({
    this.onPostCreated,
    super.key,
  });

  @override
  State<CreateTextPostScreen> createState() => _CreateTextPostScreenState();
}

class _CreateTextPostScreenState extends State<CreateTextPostScreen> {
  final TextEditingController _textController = TextEditingController();

  PostType _selectedType = PostType.general;
  XFile? _selectedImage;
  bool _hasText = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  /// Paylaşım butonunun aktif olup olmadığını belirler.
  bool get _canSubmit => (_hasText || _selectedImage != null) && !_isLoading;

  Future<void> _submitPost() async {
    if (!_canSubmit) return;

    setState(() => _isLoading = true);

    // R2 upload ve Firestore URL kaydı bu issue kapsamında değildir.
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    _textController.clear();
    setState(() {
      _isLoading = false;
      _hasText = false;
      _selectedImage = null;
      _selectedType = PostType.general;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gönderiniz başarıyla paylaşıldı.'),
        backgroundColor: AppColors.success,
      ),
    );

    if (widget.onPostCreated != null) {
      widget.onPostCreated!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni Gönderi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Post Türü Seçici
              _buildTypeSelector(),

              const SizedBox(height: AppSpacing.xl),

              // Metin Giriş Alanı
              AppTextField(
                hint: 'Ne düşünüyorsun?',
                controller: _textController,
                maxLines: 5,
                enabled: !_isLoading,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Görsel Seçici ve Önizleme
              PostImagePicker(
                selectedImage: _selectedImage,
                enabled: !_isLoading,
                onImageChanged: (image) {
                  setState(() => _selectedImage = image);
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Paylaş Butonu
              PrimaryButton(
                text: 'Paylaş',
                isLoading: _isLoading,
                isDisabled: !_canSubmit,
                onPressed: _canSubmit ? _submitPost : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
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
            final isSelected = type == _selectedType;
            return ChoiceChip(
              label: Text(_labelForType(type)),
              selected: isSelected,
              onSelected: _isLoading
                  ? null
                  : (selected) {
                      if (selected) {
                        setState(() => _selectedType = type);
                      }
                    },
              selectedColor: AppColors.primaryIndigo,
              backgroundColor: AppColors.surface,
              labelStyle: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryIndigo
                      : AppColors.border,
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _labelForType(PostType type) {
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
