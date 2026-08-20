/// Post türlerini tanımlayan enum.
///
/// Firestore `posts` koleksiyonundaki `type` alanına karşılık gelir.
enum PostType {
  general('general'),
  campus('campus'),
  announcement('announcement');

  final String value;
  const PostType(this.value);

  /// String değerden [PostType] enum nesnesine dönüştürür.
  /// Tanınmayan veya null değerler için varsayılan olarak [PostType.general] döner.
  static PostType fromString(String? typeStr) {
    switch (typeStr) {
      case 'campus':
        return PostType.campus;
      case 'announcement':
        return PostType.announcement;
      case 'general':
      default:
        return PostType.general;
    }
  }
}
