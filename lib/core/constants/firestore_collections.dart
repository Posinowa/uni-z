/// Firestore collection isimlerini merkezi olarak tanımlar.
///
/// Tüm collection referansları bu sınıf üzerinden alınmalıdır.
/// Hardcoded string kullanımı yasaktır.
///
/// Kullanım:
/// ```dart
/// FirestoreCollections.users // → 'users'
/// FirestoreCollections.posts // → 'posts'
/// ```
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String universities = 'universities';
  static const String departments = 'departments';
  static const String posts = 'posts';
  static const String postLikes = 'postLikes';
  static const String courses = 'courses';
  static const String courseMaterials = 'courseMaterials';
  static const String events = 'events';
  static const String reports = 'reports';
  static const String notifications = 'notifications';
}
