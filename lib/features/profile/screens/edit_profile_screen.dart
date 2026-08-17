import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/inputs/app_dropdown_field.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../widgets/profile_form_section.dart';

/// Kullanıcı profil düzenleme ekranı.
///
/// Firestore'dan mevcut kullanıcı bilgilerini çeker ve formda gösterir.
/// Kullanıcı şu alanları güncelleyebilir:
/// - Ad soyad (zorunlu)
/// - Telefon (opsiyonel)
/// - Sınıf (zorunlu)
/// - Tahmini mezuniyet yılı (zorunlu)
///
/// Kaydet butonuna basıldığında Firestore'daki profil güncellenir.
/// Başarılı güncelleme sonrası profil ekranına geri dönülür.
///
/// Kapsam dışı: Profil fotoğrafı, üniversite ve bölüm değiştirme.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({required this.profile, super.key});

  /// Düzenlenecek mevcut profil bilgisi.
  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;

  int? _selectedClassYear;
  int? _selectedGraduationYear;

  bool _isLoading = false;
  String? _errorMessage;

  // Sınıf seçenekleri: 1–6
  static const List<int> _classYears = [1, 2, 3, 4, 5, 6];

  // Tahmini mezuniyet yılı: bu yıldan 8 yıl sonrasına kadar
  static final List<int> _graduationYears = List.generate(
    9,
    (index) => DateTime.now().year + index,
  );

  @override
  void initState() {
    super.initState();
    // Mevcut profil bilgileriyle controller'ları başlat
    _fullNameController = TextEditingController(
      text: widget.profile.fullName,
    );
    _phoneController = TextEditingController(
      text: widget.profile.phone ?? '',
    );
    _selectedClassYear = widget.profile.classYear;
    _selectedGraduationYear = widget.profile.expectedGraduationYear;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Kaydet butonuna basıldığında çalışır.
  ///
  /// Form validasyonunu geçerse Firestore'daki profili günceller
  /// ve başarılı durumda geri döner.
  Future<void> _onSavePressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _errorMessage = 'Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedProfile = widget.profile.copyWith(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        classYear: _selectedClassYear,
        expectedGraduationYear: _selectedGraduationYear,
        updatedAt: DateTime.now(),
      );

      await _profileService.updateUserProfile(updatedProfile);

      if (!mounted) return;
      Navigator.pop(context, true); // true: güncelleme yapıldı sinyali
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Profil güncellenemedi. Lütfen tekrar deneyin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        centerTitle: true,
      ),
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
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Kişisel Bilgiler ──
                  const ProfileFormSection(title: 'Kişisel Bilgiler'),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    label: 'Ad Soyad',
                    hint: 'Adınızı ve soyadınızı girin',
                    controller: _fullNameController,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ad soyad zorunludur.';
                      }
                      if (value.trim().length < 3) {
                        return 'En az 3 karakter giriniz.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: 'Telefon (opsiyonel)',
                    hint: '05xx xxx xx xx',
                    controller: _phoneController,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Eğitim Bilgileri ──
                  const ProfileFormSection(title: 'Eğitim Bilgileri'),
                  const SizedBox(height: AppSpacing.lg),

                  AppDropdownField<int>(
                    label: 'Sınıf',
                    hint: 'Sınıfınızı seçin',
                    value: _selectedClassYear,
                    prefixIcon: Icons.class_outlined,
                    items: _classYears
                        .map(
                          (year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text('$year. Sınıf'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedClassYear = value);
                    },
                    validator: (value) {
                      if (value == null) return 'Sınıf seçimi zorunludur.';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppDropdownField<int>(
                    label: 'Tahmini Mezuniyet Yılı',
                    hint: 'Mezuniyet yılınızı seçin',
                    value: _selectedGraduationYear,
                    prefixIcon: Icons.calendar_today_outlined,
                    items: _graduationYears
                        .map(
                          (year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text('$year'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedGraduationYear = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Mezuniyet yılı seçimi zorunludur.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Hata Mesajı ──
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // ── Kaydet Butonu ──
                  PrimaryButton(
                    text: 'Kaydet',
                    onPressed: _isLoading ? null : _onSavePressed,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
