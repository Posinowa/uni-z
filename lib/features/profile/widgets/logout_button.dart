import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/buttons/outline_button.dart';
import '../../auth/providers/auth_provider.dart';

/// Kullanıcı oturumunu kapatan çıkış yap butonu bileşeni.
///
/// Tıklandığında [AuthProvider.logout] çağırır.
/// Hata oluşursa [SnackBar] ile kullanıcıya bildirir.
/// Başarılı çıkış sonrası [AppRoutes.login] ekranına yönlendirir
/// ve kullanıcının geri tuşuyla home ekranına dönmesini engeller.
class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    this.text = 'Çıkış Yap',
  });

  final String text;

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    await authProvider.logout();

    if (!context.mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
      authProvider.clearError();
    } else if (!authProvider.isLoggedIn) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return OutlineButton(
      text: text,
      icon: Icons.logout,
      isLoading: isLoading,
      onPressed: isLoading ? null : () => _handleLogout(context),
    );
  }
}
