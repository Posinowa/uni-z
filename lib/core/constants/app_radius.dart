import 'package:flutter/material.dart';

/// Uni'z uygulaması genelinde kullanılacak köşe yuvarlaklık (radius) sabitleri.
///
/// Tutarlı border-radius değerleri için bu sabitler kullanılmalıdır.
class AppRadius {
  AppRadius._(); // Instance oluşturulmasını engeller.

  /// 4px — Çok küçük yuvarlaklık (badge, chip gibi).
  static const double xs = 4.0;

  /// 8px — Küçük yuvarlaklık (buton gibi).
  static const double sm = 8.0;

  /// 12px — Orta yuvarlaklık (kart gibi).
  static const double md = 12.0;

  /// 16px — Büyük yuvarlaklık (bottom sheet gibi).
  static const double lg = 16.0;

  /// 24px — Çok büyük yuvarlaklık (dialog, modal gibi).
  static const double xl = 24.0;

  /// Tam daire — Avatar, FAB gibi.
  static const double full = 999.0;

  // ─── Hazır BorderRadius Nesneleri ──────────────────────────────

  /// 4px BorderRadius.
  static final BorderRadius borderRadiusXs = BorderRadius.circular(xs);

  /// 8px BorderRadius.
  static final BorderRadius borderRadiusSm = BorderRadius.circular(sm);

  /// 12px BorderRadius.
  static final BorderRadius borderRadiusMd = BorderRadius.circular(md);

  /// 16px BorderRadius.
  static final BorderRadius borderRadiusLg = BorderRadius.circular(lg);

  /// 24px BorderRadius.
  static final BorderRadius borderRadiusXl = BorderRadius.circular(xl);

  /// Tam daire BorderRadius.
  static final BorderRadius borderRadiusFull = BorderRadius.circular(full);
}
