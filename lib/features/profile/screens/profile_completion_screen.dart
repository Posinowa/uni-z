import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_universities.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_dropdown_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../widgets/department_input_field.dart';
import '../widgets/profile_form_section.dart';

/// Kayıt sonrası profil tamamlama ekranı.
///
/// Kullanıcıdan şu bilgiler alınır:
/// - Ad soyad (zorunlu)
/// - Telefon (opsiyonel)
/// - Üniversite (zorunlu)
/// - Bölüm (zorunlu)
/// - Sınıf (zorunlu)
/// - Tahmini mezuniyet yılı (zorunlu)
///
/// Firestore kaydı bu ekranda yapılmaz. Sadece form UI ve validasyon içerir.
class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  /// Seçilen üniversite — id ve name içerir.
  UniversityEntry? _selectedUniversity;
  /// Seçilen veya manuel girilen bölüm adı.
  String? _departmentName;
  int? _selectedClassYear;
  int? _selectedGraduationYear;

  // Sınıf seçenekleri: 1–6
  static const List<int> _classYears = [1, 2, 3, 4, 5, 6];

  // Tahmini mezuniyet yılı: bu yıldan 8 yıl sonrasına kadar
  static final List<int> _graduationYears = List.generate(
    9,
    (index) => DateTime.now().year + index,
  );

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Kaydet butonuna basıldığında form validasyonu çalışır.
  void _onSavePressed() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // _departmentName burada hazır; Firestore kaydı kapsam dışı.
    // Başarılı validasyon sonrası snackbar gösterilir.
    final _ = _departmentName;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil bilgileri kaydedildi.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxxl),

                  // ── Üst Alan ──
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xxxl),

                  // ── Kişisel Bilgiler ──
                  const ProfileFormSection(title: 'Kişisel Bilgiler'),
                  const SizedBox(height: AppSpacing.lg),

                  // Ad Soyad
                  AppTextField(
                    label: 'Ad Soyad',
                    hint: 'Adınızı ve soyadınızı girin',
                    controller: _fullNameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ad soyad gerekli';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Telefon (opsiyonel)
                  AppTextField(
                    label: 'Telefon (opsiyonel)',
                    hint: '05xx xxx xx xx',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Eğitim Bilgileri ──
                  const ProfileFormSection(title: 'Eğitim Bilgileri'),
                  const SizedBox(height: AppSpacing.lg),

                  // Üniversite — kTurkishUniversities sabitinden beslenir
                  AppDropdownField<UniversityEntry>(
                    label: 'Üniversite',
                    hint: 'Üniversitenizi seçin',
                    value: _selectedUniversity,
                    prefixIcon: Icons.school_outlined,
                    items: kTurkishUniversities
                        .map(
                          (uni) => DropdownMenuItem(
                            value: uni,
                            child: Text(uni.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedUniversity = value),
                    validator: (value) {
                      if (value == null) return 'Üniversite seçimi zorunludur';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Bölüm — dropdown veya manuel giriş
                  DepartmentInputField(
                    onDepartmentChanged: (value) =>
                        setState(() => _departmentName = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Sınıf
                  AppDropdownField<int>(
                    label: 'Sınıf',
                    hint: 'Sınıfınızı seçin',
                    value: _selectedClassYear,
                    prefixIcon: Icons.class_outlined,
                    items: _classYears
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text('$year. Sınıf'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedClassYear = value),
                    validator: (value) {
                      if (value == null) return 'Sınıf seçimi zorunludur';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Tahmini Mezuniyet Yılı
                  AppDropdownField<int>(
                    label: 'Tahmini Mezuniyet Yılı',
                    hint: 'Yıl seçin',
                    value: _selectedGraduationYear,
                    prefixIcon: Icons.calendar_today_outlined,
                    items: _graduationYears
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text('$year'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedGraduationYear = value),
                    validator: (value) {
                      if (value == null) {
                        return 'Mezuniyet yılı seçimi zorunludur';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // ── Kaydet Butonu ──
                  PrimaryButton(
                    text: 'Profili Tamamla',
                    onPressed: _onSavePressed,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Üst başlık ve açıklama alanı.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gradient ikonu
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Profili Tamamla',
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Üniversite hayatın tek yerde başlıyor.\nBilgilerini girerek topluluğa katıl.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
