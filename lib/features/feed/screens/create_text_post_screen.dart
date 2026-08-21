import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../models/post_type.dart';
import '../widgets/post_type_selector.dart';

/// Metin postu oluşturma ekranı.
///
/// Kullanıcı post türü seçip metin girişi yapar.
/// Metin boşken paylaş butonu devre dışı kalır.
/// Bu aşamada Firestore kaydı yapılmaz; sadece UI.
class CreateTextPostScreen extends StatefulWidget {
  const CreateTextPostScreen({super.key});

  @override
  State<CreateTextPostScreen> createState() => _CreateTextPostScreenState();
}

class _CreateTextPostScreenState extends State<CreateTextPostScreen> {
  final _textController = TextEditingController();

  /// Seçili post türü. Varsayılan: Genel.
  PostType _selectedType = PostType.general;

  /// Metin alanının boş olup olmadığını takip eder.
  bool _hasText = false;

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

  void _onShare() {
    // Firestore kaydı bu issue kapsamında değil.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gönderi paylaşma özelliği yakında eklenecek.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Gönderi'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Post türü seçici
              PostTypeSelector(
                selectedType: _selectedType,
                onChanged: (type) {
                  setState(() => _selectedType = type);
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // Metin giriş alanı
              AppTextField(
                hint: 'Ne düşünüyorsun?',
                controller: _textController,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Paylaş butonu
              PrimaryButton(
                text: 'Paylaş',
                onPressed: _hasText ? _onShare : null,
                isDisabled: !_hasText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
