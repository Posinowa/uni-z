import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

/// Banlanan (kısıtlanan) kullanıcılar için bilgilendirme ekranı.
///
/// Banlı kullanıcının ana akışa ve işlem ekranlarına geçişini engeller.
/// Kullanıcıya açık ve kibar bir mesaj, kısıtlanan işlemler listesi
/// ve oturumu kapatarak giriş ekranına dönme imkânı sunar.
class BannedUserScreen extends StatefulWidget {
  const BannedUserScreen({
    this.banReason,
    this.authService,
    this.onLogout,
    super.key,
  });

  /// Opsiyonel ban / kısıtlama gerekçesi.
  final String? banReason;

  /// Test ve özel durumlar için opsiyonel [AuthService].
  final AuthService? authService;

  /// Test ve özel durumlar için opsiyonel logout geri çağrımı.
  final VoidCallback? onLogout;

  @override
  State<BannedUserScreen> createState() => _BannedUserScreenState();
}

class _BannedUserScreenState extends State<BannedUserScreen> {
  bool _isLoggingOut = false;

  /// Oturumu kapatıp kullanıcıyı giriş ekranına yönlendirir.
  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      if (widget.onLogout != null) {
        widget.onLogout!();
      } else if (widget.authService != null) {
        await widget.authService!.signOut();
      } else {
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();
      }
    } catch (_) {
      // Hata olsa dahi kullanıcıyı login ekranına güvenle yönlendir
    }

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Kısıtlama İkonu ──
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.block_rounded,
                          size: 52,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Başlık ──
                    Text(
                      'Hesabınız Kısıtlandı',
                      style: AppTextStyles.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Kibar Bilgilendirme Mesajı ──
                    Text(
                      'Topluluk kurallarımız veya kullanım koşullarımızın ihlali nedeniyle hesabınız geçici olarak kısıtlanmıştır.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Opsiyonel Ban Sebebi Kartı ──
                    if (widget.banReason != null &&
                        widget.banReason!.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kısıtlama Gerekçesi',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.banReason!.trim(),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // ── Kısıtlanan İşlemler Kartı ──
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kısıtlanan İşlemler',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildRestrictionRow(
                            Icons.post_add_outlined,
                            'İçerik ve gönderi paylaşma',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildRestrictionRow(
                            Icons.upload_file_outlined,
                            'Ders notu ve materyal yükleme',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildRestrictionRow(
                            Icons.favorite_border_rounded,
                            'Gönderi ve içerikleri beğenme',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildRestrictionRow(
                            Icons.flag_outlined,
                            'Rapor ve talep oluşturma',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── İletişim & Destek Bilgisi ──
                    Text(
                      'Bir yanlışlık olduğunu düşünüyorsanız lütfen destek ekibimizle iletişime geçin.\nDestek: destek@uniz.app',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Çıkış Yap Butonu ──
                    PrimaryButton(
                      text: 'Çıkış Yap',
                      onPressed: _isLoggingOut ? null : _handleLogout,
                      isLoading: _isLoggingOut,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Kısıtlanan işlem maddesini oluşturan yardımcı widget.
  Widget _buildRestrictionRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.error.withValues(alpha: 0.8),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
