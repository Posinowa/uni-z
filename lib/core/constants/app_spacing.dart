/// Uni'z uygulaması genelinde kullanılacak boşluk (spacing) sabitleri.
///
/// 4px tabanlı ölçek sistemi kullanılır.
/// Tutarlı boşluklar için padding, margin ve gap değerlerinde
/// bu sabitler kullanılmalıdır.
class AppSpacing {
  AppSpacing._(); // Instance oluşturulmasını engeller.

  /// 4px — Çok küçük boşluk (ikon-metin arası gibi).
  static const double xs = 4.0;

  /// 8px — Küçük boşluk (liste öğeleri arası gibi).
  static const double sm = 8.0;

  /// 12px — Küçük-orta boşluk.
  static const double md = 12.0;

  /// 16px — Standart boşluk (kart padding'i gibi).
  static const double lg = 16.0;

  /// 20px — Orta-büyük boşluk.
  static const double xl = 20.0;

  /// 24px — Büyük boşluk (section arası gibi).
  static const double xxl = 24.0;

  /// 32px — Çok büyük boşluk (sayfa kenar boşlukları gibi).
  static const double xxxl = 32.0;
}
