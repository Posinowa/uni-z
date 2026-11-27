import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/user_profile.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_form_section.dart';
import 'edit_profile_screen.dart';

/// Kullanıcı ayarları ekranı.
///
/// Profil düzenleme, uygulama tercihleri ve oturum yönetimi seçeneklerini
/// tek çatı altında toplar. Profil güncellendiğinde geri dönüşte `true` döner.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.profile,
    super.key,
  });

  /// Mevcut kullanıcı profili.
  final UserProfile profile;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _profileUpdated = false;

  Future<void> _navigateToEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: widget.profile),
      ),
    );
    if (updated == true && mounted) {
      setState(() => _profileUpdated = true);
    }
  }

  void _showComingSoonMessage(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName özelliği yakında eklenecektir.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _profileUpdated);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Ayarlar'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Hesap Ayarları ──
                  _buildSectionCard(
                    title: 'Hesap',
                    children: [
                      _SettingsTile(
                        icon: Icons.edit_outlined,
                        title: 'Profili Düzenle',
                        subtitle: 'Ad, telefon, sınıf ve mezuniyet bilgileri',
                        onTap: _navigateToEditProfile,
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _SettingsTile(
                        icon: Icons.manage_accounts_outlined,
                        title: 'Hesap Yönetimi',
                        subtitle: 'Hesabı dondurma veya silme',
                        trailingText: 'Yakında',
                        onTap: () => _showComingSoonMessage('Hesap Yönetimi'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Uygulama Tercihleri ──
                  _buildSectionCard(
                    title: 'Tercihler',
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Bildirim Tercihleri',
                        subtitle: 'Beğeni, etkinlik ve ders bildirimleri',
                        trailingText: 'Yakında',
                        onTap: () =>
                            _showComingSoonMessage('Bildirim Tercihleri'),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Görünüm',
                        subtitle: 'Aydınlık / Karanlık mod',
                        trailingText: 'Yakında',
                        onTap: () => _showComingSoonMessage('Karanlık Mod'),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _SettingsTile(
                        icon: Icons.language_outlined,
                        title: 'Dil',
                        subtitle: 'Uygulama dili',
                        trailingText: 'Türkçe',
                        onTap: () => _showComingSoonMessage('Çoklu Dil'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Oturum ──
                  const LogoutButton(),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: ProfileFormSection(title: title),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: Icon(icon, color: AppColors.primaryIndigo),
      title: Text(title, style: AppTextStyles.labelLarge),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
