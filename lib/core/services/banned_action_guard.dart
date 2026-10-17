import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../features/profile/services/profile_service.dart';
import '../constants/app_colors.dart';

/// Banlı kullanıcıların kritik aksiyonlarını (post, like, rapor, ders, materyal, etkinlik)
/// merkezi olarak denetleyen ve engelleyen servis sınıfı.
///
/// Ban kontrolü mantığını tek noktada toplar; tüm özellikler (features)
/// bu sınıfı kullanarak tutarlı bir kısıtlama ve kullanıcı deneyimi sunar.
class BannedActionGuard {
  BannedActionGuard._();

  /// Banlı kullanıcıya gösterilecek merkezi uyarı mesajı.
  static const String bannedMessage =
      'Hesabınız geçici olarak kısıtlanmıştır. Bu işlemi şu anda gerçekleştiremezsiniz.';

  /// Testlerde sahte/mock servis enjeksiyonu için opsiyonel mock instance.
  static ProfileService? mockProfileService;
  static FirebaseAuth? mockAuth;

  /// Belirtilen veya aktif kullanıcının banlı olup olmadığını kontrol eder.
  ///
  /// [userId] verilmezse [FirebaseAuth.instance.currentUser?.uid] kullanılır.
  /// Kullanıcı oturum açmamışsa veya banlı değilse `false` döner.
  static Future<bool> isBanned({
    String? userId,
    ProfileService? profileService,
    FirebaseAuth? auth,
  }) async {
    try {
      final effectiveUid =
          userId ?? (auth ?? mockAuth ?? FirebaseAuth.instance).currentUser?.uid;

      if (effectiveUid == null || effectiveUid.trim().isEmpty) {
        return false;
      }

      final service = profileService ?? mockProfileService ?? ProfileService();
      return await service.isUserBanned(effectiveUid);
    } catch (_) {
      return false;
    }
  }

  /// Kullanıcının aksiyonu yapmasına izin verilip verilmediğini kontrol eder.
  ///
  /// - Kullanıcı **banlıysa**: Standart kısıtlama mesajını SnackBar olarak gösterir,
  ///   opsiyonel [onBanned] callback'ini tetikler ve `false` döner.
  /// - Kullanıcı **banlı değilse**: `true` döner ve aksiyonun devam etmesine izin verir.
  ///
  /// Örnek Kullanım:
  /// ```dart
  /// if (!await BannedActionGuard.check(context, userId: uid)) return;
  /// // Kritik işlem devam eder...
  /// ```
  static Future<bool> check(
    BuildContext context, {
    String? userId,
    ProfileService? profileService,
    FirebaseAuth? auth,
    VoidCallback? onBanned,
  }) async {
    final banned = await isBanned(
      userId: userId,
      profileService: profileService,
      auth: auth ?? mockAuth,
    );

    if (banned) {
      if (context.mounted) {
        showBannedSnackBar(context);
      }
      onBanned?.call();
      return false;
    }

    return true;
  }

  /// Banlı kullanıcı için standart hata SnackBar'ını gösterir.
  static void showBannedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(bannedMessage),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
