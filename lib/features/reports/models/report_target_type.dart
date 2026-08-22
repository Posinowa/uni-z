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
  /// Tanınmayan veya null değerler için varsayılan olarak [ReportTargetType.post] döner.
  static ReportTargetType fromString(String? typeStr) {
    switch (typeStr) {
      case 'material':
        return ReportTargetType.material;
      case 'event':
        return ReportTargetType.event;
      case 'user':
        return ReportTargetType.user;
      case 'post':
      default:
        return ReportTargetType.post;
    }
  }
}
