import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_form_section.dart';
import '../widgets/profile_info_row.dart';

/// Kullanıcı profil ekranı.
///
/// Firestore'dan kullanıcının profil bilgilerini çekerek gösterir:
/// - Profil fotoğrafı placeholder (baş harf)
/// - Ad soyad
/// - Üniversite, bölüm, sınıf, mezuniyet yılı
/// - Katılım tarihi
///
/// Kapsam dışı: Profil düzenleme, takip sistemi, post listeleme.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();

  UserProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Firestore'dan profil bilgilerini yükler.
  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kullanıcı bilgisi alınamadı.';
      });
      return;
    }

    try {
      final profile = await _profileService.getUserProfile(uid);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Profil bilgileri yüklenemedi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryIndigo),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            _errorMessage!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_profile == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Text('Profil bilgisi bulunamadı.'),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xxl),

            // ── Avatar + İsim ──
            _buildAvatarSection(),
            const SizedBox(height: AppSpacing.xxl),

            // ── Eğitim Bilgileri Kartı ──
            _buildInfoCard(),
            const SizedBox(height: AppSpacing.xxl),

            // ── Çıkış ──
            const LogoutButton(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  /// Profil fotoğrafı placeholder ve ad soyad alanı.
  Widget _buildAvatarSection() {
    final initials = _profile!.fullName.isNotEmpty
        ? _profile!.fullName[0].toUpperCase()
        : 'U';

    return Column(
      children: [
        // Gradient avatar placeholder
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Ad soyad
        Text(
          _profile!.fullName,
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),

        // E-posta
        Text(
          _profile!.email,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Eğitim bilgileri ve katılım tarihi kartı.
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Eğitim Bilgileri başlığı ──
          const ProfileFormSection(title: 'Eğitim Bilgileri'),
          const SizedBox(height: AppSpacing.lg),

          ProfileInfoRow(
            icon: Icons.school_outlined,
            label: 'Üniversite',
            value: _profile!.universityName,
          ),
          const SizedBox(height: AppSpacing.md),

          ProfileInfoRow(
            icon: Icons.book_outlined,
            label: 'Bölüm',
            value: _profile!.departmentName.isNotEmpty
                ? _profile!.departmentName
                : '—',
          ),
          const SizedBox(height: AppSpacing.md),

          ProfileInfoRow(
            icon: Icons.class_outlined,
            label: 'Sınıf',
            value: '${_profile!.classYear}. Sınıf',
          ),
          const SizedBox(height: AppSpacing.md),

          ProfileInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tahmini Mezuniyet',
            value: '${_profile!.expectedGraduationYear}',
          ),

          // ── Hesap Bilgileri başlığı ──
          if (_profile!.createdAt != null) ...[
            const SizedBox(height: AppSpacing.xl),
            const ProfileFormSection(title: 'Hesap Bilgileri'),
            const SizedBox(height: AppSpacing.lg),
            ProfileInfoRow(
              icon: Icons.calendar_month_outlined,
              label: 'Katılım Tarihi',
              value: _formatDate(_profile!.createdAt!),
            ),
          ],
        ],
      ),
    );
  }

  /// [DateTime] nesnesini "Ağustos 2026" formatında döndürür.
  String _formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
