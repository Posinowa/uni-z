import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Uni'z uygulaması genelinde kullanılacak metin stilleri.
///
/// Material 3 tipografi ölçeğine uygun şekilde hazırlanmıştır.
/// Renkler [AppColors] sınıfından alınır.
class AppTextStyles {
  AppTextStyles._(); // Instance oluşturulmasını engeller.

  // ─── Heading ───────────────────────────────────────────────────

  /// Büyük başlık — Splash, onboarding gibi öne çıkan ekranlar.
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Orta başlık — Sayfa başlıkları.
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Küçük başlık — Section başlıkları.
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ─── Title ─────────────────────────────────────────────────────

  /// Büyük title — Kart başlıkları, liste başlıkları.
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Orta title — Alt başlıklar.
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Küçük title — Etiketler, badge metinleri.
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ─── Body ──────────────────────────────────────────────────────

  /// Büyük body — Ana içerik metinleri.
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Orta body — Standart paragraf metni.
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Küçük body — Açıklama, yardımcı metin.
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ─── Label ─────────────────────────────────────────────────────

  /// Büyük label — Buton metinleri.
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Orta label — Input label, tab metni.
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Küçük label — Caption, zaman damgası.
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}
