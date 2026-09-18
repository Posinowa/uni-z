import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_dropdown_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../widgets/course_detail_args.dart';
import '../widgets/material_file_picker.dart';

/// Ders Notu veya Çıkmış Soru Yükleme Ekranı (Issue #53).
///
/// Kullanıcı bu ekrandan ders materyali (not, çıkmış soru, özet vb.)
/// yüklemek için gerekli form alanlarını doldurur.
///
/// Telif hakkı uyarısı checkbox'ı işaretlenmeden "Yükle" butonu aktif olmaz.
/// Gerçek dosya yükleme ve Firestore kayıt işlemleri kapsam dışıdır.
class UploadMaterialScreen extends StatefulWidget {
  const UploadMaterialScreen({
    super.key,
    this.courseArgs,
  });

  /// İlgili ders bilgileri (opsiyonel).
  final CourseDetailArgs? courseArgs;

  /// Bu ekran için rota adı.
  static const String routeName = '/upload-material';

  /// Rota oluşturucu yardımcı metod.
  static Route<dynamic> route({CourseDetailArgs? courseArgs}) {
    return MaterialPageRoute<dynamic>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => UploadMaterialScreen(courseArgs: courseArgs),
    );
  }

  @override
  State<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends State<UploadMaterialScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// Seçili materyal tipi.
  String? _selectedMaterialType;

  /// Seçili dosya.
  XFile? _selectedFile;

  /// Telif hakkı uyarısının kabul edilip edilmediği.
  bool _isDisclaimerAccepted = false;

  /// Form gönderim durumu (UI animasyonu için).
  bool _isLoading = false;

  /// Desteklenen materyal tipleri (Issue #53 tanımı).
  static const List<String> _materialTypes = [
    'Ders notu',
    'Çıkmış soru',
    'Özet',
    'Diğer',
  ];

  /// Telif uyarısı metni (PROJECT_CONTEXT.md Bölüm 20 / Issue #53).
  static const String _disclaimerText =
      'Yüklediğim dosyanın paylaşımından sorumlu olduğumu, '
      'telif hakkı veya kişisel veri ihlali içermediğini kabul ediyorum.';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Form doğrulamasını yapar ve gönderme akışını tamamlar.
  void _onSubmit() {
    // 1. Form alanları doğrulaması
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 2. Dosya seçilmiş mi kontrolü
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen yüklenecek bir dosya seçin.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 3. Telif hakkı kabulü kontrolü
    if (!_isDisclaimerAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen telif hakkı uyarısını onaylayın.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Gerçek upload ve Firestore kaydı kapsam dışıdır.
    // Başarı bildirimi verilip ekran kapatılır.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ders materyali başarıyla yüklendi. Admin onayından sonra yayınlanacaktır.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );

      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materyal Yükle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ders Bilgisi Kartı (Varsa) ──
              if (widget.courseArgs != null) ...[
                _buildCourseInfoBanner(widget.courseArgs!),
                const SizedBox(height: AppSpacing.lg),
              ],

              // ── Başlık ──
              Text(
                'Başlık',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppTextField(
                hint: 'Örn: 2024 Vize Çıkmış Soruları ve Çözümleri',
                controller: _titleController,
                prefixIcon: Icons.title_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Başlık boş bırakılamaz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Açıklama (Opsiyonel) ──
              Text(
                'Açıklama (Opsiyonel)',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppTextField(
                hint: 'Materyal içeriği hakkında kısa bir bilgi verin...',
                controller: _descriptionController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Materyal Tipi ──
              Text(
                'Materyal Tipi',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppDropdownField<String>(
                hint: 'Materyal tipini seçin',
                value: _selectedMaterialType,
                prefixIcon: Icons.category_outlined,
                items: _materialTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedMaterialType = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen materyal tipi seçiniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Dosya Seçimi ──
              Text(
                'Dosya',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              MaterialFilePicker(
                selectedFile: _selectedFile,
                onFileChanged: (file) {
                  setState(() => _selectedFile = file);
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Telif Hakkı Uyarısı ve Checkbox ──
              _buildDisclaimerCheckbox(),
              const SizedBox(height: AppSpacing.xxl),

              // ── Yükle Butonu ──
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Yükle',
                  icon: Icons.cloud_upload_outlined,
                  // Checkbox işaretlenmeden buton aktif olmamalı
                  onPressed: _isDisclaimerAccepted && !_isLoading
                      ? _onSubmit
                      : null,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// Ders bilgisi gösteren üst rozet/kart.
  Widget _buildCourseInfoBanner(CourseDetailArgs args) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryIndigo.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primaryIndigo.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              args.courseCode,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              args.courseName,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Telif hakkı onay alanı ve uyarısı.
  Widget _buildDisclaimerCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: InkWell(
        onTap: () {
          setState(() {
            _isDisclaimerAccepted = !_isDisclaimerAccepted;
          });
        },
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _isDisclaimerAccepted,
                activeColor: AppColors.primaryIndigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                onChanged: (value) {
                  setState(() {
                    _isDisclaimerAccepted = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _disclaimerText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
