/// Kullanıcı rollerini tanımlayan enum.
///
/// Firestore `users` koleksiyonundaki `role` alanına karşılık gelir.
enum UserRole {
  student('student'),
  admin('admin'),
  community('community');

  final String value;
  const UserRole(this.value);

  /// String değerden [UserRole] enum nesnesine dönüştürür.
  /// Tanınmayan veya null değerler için varsayılan olarak [UserRole.student] döner.
  static UserRole fromString(String? roleStr) {
    switch (roleStr) {
      case 'admin':
        return UserRole.admin;
      case 'community':
        return UserRole.community;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}
