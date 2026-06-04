import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Yükleme durumunu gösteren merkezi spinner widget'ı.
///
/// Liste, ekran veya herhangi bir async işlem beklenirken kullanılır.
/// Ekranın ortasına konumlanır ve tema renklerini kullanır.
///
/// Örnek:
/// ```dart
/// if (isLoading) return const AppLoadingView();
/// ```
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryIndigo,
        strokeWidth: 3,
      ),
    );
  }
}
