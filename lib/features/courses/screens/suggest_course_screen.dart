import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../services/course_suggestion_service.dart';

/// Ders Önerisi Gönderme Ekranı.
///
/// Kullanıcı bu ekrandan yeni bir ders önerisi gönderebilir.
/// Form gönderildikten sonra ders, Firestore'a `status: pending`
/// olarak kaydedilir. Admin onaylamadan listede görünmez.
class SuggestCourseScreen extends StatefulWidget {
  const SuggestCourseScreen({super.key});

  /// Bu ekran için route adı.
  static const String routeName = '/suggest-course';

  /// Kolay rota oluşturucu.
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => const SuggestCourseScreen(),
    );
  }

  @override
  State<SuggestCourseScreen> createState() => _SuggestCourseScreenState();
}

class _SuggestCourseScreenState extends State<SuggestCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _service = CourseSuggestionService();

  bool _isLoading = false;

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _departmentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Form doğrulamasını yapar ve Firestore'a kaydeder.
  Future<void> _onSubmit() async {
    // Validasyon başarısız olursa erken çık.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Giriş yapmış kullanıcı zorunlu.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('Ders önerisi göndermek için giriş yapmalısınız.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _service.suggestCourse(
        userId: user.uid,
        courseCode: _courseCodeController.text,
        courseName: _courseNameController.text,
        department: _departmentController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      if (!mounted) return;

      // Başarı mesajı göster ve ekranı kapat.
      _showSuccessAndPop();
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Başarı mesajını gösterip ekranı kapatır.
  void _showSuccessAndPop() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Ders öneriniz admin onayından sonra yayınlanacaktır.',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
    Navigator.of(context).pop();
  }

  /// Hata SnackBar'ı gösterir.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Öner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Bilgi Banner'ı ──
              _buildInfoBanner(),
              const SizedBox(height: AppSpacing.xxl),

              // ── Ders Kodu ──
              Text(
                'Ders Kodu',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppTextField(
                hint: 'Örn: CS101',
                controller: _courseCodeController,
                prefixIcon: Icons.tag,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ders kodu boş bırakılamaz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Ders Adı ──
              Text(
                'Ders Adı',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppTextField(
                hint: 'Örn: Veri Yapıları ve Algoritmalar',
                controller: _courseNameController,
                prefixIcon: Icons.book_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ders adı boş bırakılamaz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Bölüm ──
              Text(
                'Bölüm',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppTextField(
                hint: 'Örn: Bilgisayar Mühendisliği',
                controller: _departmentController,
                prefixIcon: Icons.school_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bölüm boş bırakılamaz.';
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
                hint: 'Ders hakkında kısa bir açıklama ekleyebilirsiniz.',
                controller: _descriptionController,
                maxLines: 4,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Gönder Butonu ──
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Öneriyi Gönder',
                  icon: Icons.send_outlined,
                  onPressed: _isLoading ? null : _onSubmit,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sayfanın üstünde bilgi veren açıklama kartı.
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryIndigo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: AppColors.primaryIndigo.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryIndigo,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Gönderdiğiniz ders önerisi, admin tarafından onaylandıktan sonra ders listesinde görünür hale gelecektir.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
