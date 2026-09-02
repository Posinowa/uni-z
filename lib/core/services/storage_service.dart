import 'dart:io';

/// Dosya yükleme işlemleri için soyut servis sınıfı.
///
/// Bu sınıf, storage işlemlerinin interface'ini tanımlar.
/// Gerçek implementasyon (örn. Cloudflare R2 signed upload)
/// ileride bu sınıfı extend eden bir alt sınıf ile sağlanacaktır.
///
/// Önemli: Mobil uygulama herhangi bir storage secret key
/// tutmamalıdır. Upload işlemi ileride güvenli bir endpoint
/// üzerinden (signed URL veya admin-controlled endpoint)
/// gerçekleştirilecektir.
///
/// Örnek kullanım:
/// ```dart
/// final storageService = StorageService();
/// final url = await storageService.uploadFile(
///   file: myFile,
///   folder: 'profile_images',
///   fileName: 'user123.jpg',
/// );
/// ```
abstract class StorageService {
  /// Verilen dosyayı belirtilen klasöre yükler ve dosyanın
  /// erişim URL'ini döndürür.
  ///
  /// [file] — Yüklenecek dosya.
  /// [folder] — Hedef klasör adı (örn. 'profile_images', 'course_materials').
  /// [fileName] — Dosyanın kaydedileceği isim (örn. 'user123.jpg').
  ///
  /// Başarılı upload sonrası dosyanın public URL'ini döndürür.
  ///
  /// Henüz gerçek upload implementasyonu yoktur.
  /// Gerçek implementasyon eklenene kadar [UnimplementedError] fırlatır.
  Future<String> uploadFile({
    required File file,
    required String folder,
    required String fileName,
  });

  /// Verilen dosya anahtarını (key) kullanarak dosyayı siler.
  ///
  /// [fileKey] — Silinecek dosyanın storage key'i.
  ///
  /// Henüz gerçek delete implementasyonu yoktur.
  /// Gerçek implementasyon eklenene kadar [UnimplementedError] fırlatır.
  Future<void> deleteFile({
    required String fileKey,
  });
}
