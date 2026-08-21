import 'dart:io';

import 'package:uniz_mobile/core/services/storage_service.dart';

/// [StorageService] interface'inin placeholder implementasyonu.
///
/// Bu sınıf, gerçek Cloudflare R2 upload entegrasyonu hazır
/// olana kadar kullanılacak geçici implementasyondur.
///
/// Tüm metotlar [UnimplementedError] fırlatır.
///
/// Gerçek upload hazır olduğunda bu sınıf,
/// signed URL veya admin-controlled endpoint kullanan
/// bir implementasyon ile değiştirilecektir.
///
/// Örnek:
/// ```dart
/// // Provider'da kullanım:
/// Provider<StorageService>(
///   create: (_) => R2StorageService(),
/// )
/// ```
class R2StorageService extends StorageService {
  @override
  Future<String> uploadFile({
    required File file,
    required String folder,
    required String fileName,
  }) {
    // TODO: Signed upload endpoint hazır olduğunda implement edilecek.
    throw UnimplementedError(
      'R2 upload henüz implement edilmedi. '
      'Signed upload endpoint hazır olduğunda bu metot güncellenecektir.',
    );
  }

  @override
  Future<void> deleteFile({
    required String fileKey,
  }) {
    // TODO: Delete endpoint hazır olduğunda implement edilecek.
    throw UnimplementedError(
      'R2 delete henüz implement edilmedi. '
      'Delete endpoint hazır olduğunda bu metot güncellenecektir.',
    );
  }
}
