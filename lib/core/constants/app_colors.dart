import 'package:flutter/material.dart';

/// Uni'z marka renk paleti.
///
/// Tüm renkler PROJECT_CONTEXT.md Bölüm 4'te tanımlanan
/// marka paletine uygun şekilde merkezi olarak yönetilir.
/// Uygulama genelinde hardcoded renk kullanımı yerine
/// bu sınıftaki sabitler tercih edilmelidir.
class AppColors {
  AppColors._(); // Instance oluşturulmasını engeller.

  // ─── Ana Renkler ───────────────────────────────────────────────

  /// Primary Indigo: Butonlar, aktif tab, linkler.
  static const Color primaryIndigo = Color(0xFF4F46E5);

  /// Secondary Cyan: İkincil aksiyonlar, badge, etiket.
  static const Color secondaryCyan = Color(0xFF06B6D4);

  /// Accent Purple: Vurgular, özel içerikler.
  static const Color accentPurple = Color(0xFFA855F7);

  // ─── Arka Plan & Yüzey ─────────────────────────────────────────

  /// Genel sayfa arka planı.
  static const Color background = Color(0xFFF8FAFC);

  /// Kart ve yüzey (card) arka planı.
  static const Color surface = Color(0xFFFFFFFF);

  // ─── Metin ─────────────────────────────────────────────────────

  /// Başlık ve ana metin rengi.
  static const Color textPrimary = Color(0xFF0F172A);

  /// Açıklama, alt metin, ipucu rengi.
  static const Color textSecondary = Color(0xFF64748B);

  // ─── Kenarlık ──────────────────────────────────────────────────

  /// Kart, input ve ayırıcı kenarlık rengi.
  static const Color border = Color(0xFFE2E8F0);

  // ─── Durum Renkleri ────────────────────────────────────────────

  /// Başarılı işlem, onay durumu.
  static const Color success = Color(0xFF22C55E);

  /// Uyarı, beklemede durumu.
  static const Color warning = Color(0xFFF59E0B);

  /// Hata, reddedildi, rapor durumu.
  static const Color error = Color(0xFFEF4444);

  // ─── Kategori Renkleri ─────────────────────────────────────────

  /// Dersler / Notlar kategorisi.
  static const Color categoryLectures = Color(0xFF4F46E5);

  /// Etkinlikler kategorisi.
  static const Color categoryEvents = Color(0xFFF97316);

  /// Topluluklar kategorisi.
  static const Color categoryCommunities = Color(0xFFA855F7);

  /// Kampüs Duyuruları kategorisi.
  static const Color categoryCampus = Color(0xFF06B6D4);

  /// Rapor / Uyarı kategorisi.
  static const Color categoryReport = Color(0xFFEF4444);

  /// Onaylandı kategorisi.
  static const Color categoryApproved = Color(0xFF22C55E);

  /// Beklemede kategorisi.
  static const Color categoryPending = Color(0xFFF59E0B);

  // ─── Gradient ──────────────────────────────────────────────────

  /// Splash, onboarding ve CTA alanları için marka gradient'i.
  /// PROJECT_CONTEXT.md: #4F46E5 → #06B6D4
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, secondaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
