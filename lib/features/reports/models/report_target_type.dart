import 'package:flutter/foundation.dart';

/// Raporun hangi içerik türüne ait olduğunu tanımlayan enum.
///
/// Firestore `reports` koleksiyonundaki `targetType` alanına karşılık gelir.
enum ReportTargetType {
  post('post'),
  material('material'),
  event('event'),
  user('user');

  final String value;
  const ReportTargetType(this.value);

  /// String değerden [ReportTargetType] enum nesnesine dönüştürür.
  ///
  /// Bilinmeyen veya null değerlerde sessizce varsayılana düşmek yerine
  /// [debugPrint] ile açık uyarı verir ve [ReportTargetType.post] döner.
  static ReportTargetType fromString(String? typeStr) {
    switch (typeStr) {
      case 'post':
        return ReportTargetType.post;
      case 'material':
        return ReportTargetType.material;
      case 'event':
        return ReportTargetType.event;
      case 'user':
        return ReportTargetType.user;
      case null:
        return ReportTargetType.post;
      default:
        debugPrint(
          'ReportTargetType.fromString: Tanınmayan hedef tipi "$typeStr", varsayılan post kullanıldı.',
        );
        return ReportTargetType.post;
    }
  }
}
