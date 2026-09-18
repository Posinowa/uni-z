/// Dersin onay durumunu tanımlayan enum.
///
/// Firestore `courses` koleksiyonundaki `status` alanına karşılık gelir.
/// Kullanıcı ders ekleme talebi gönderdiğinde varsayılan durum [pending] olur.
/// Admin onayından sonra [approved] veya [rejected] değerine geçer.
enum CourseStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const CourseStatus(this.value);

  /// String değerden [CourseStatus] enum nesnesine dönüştürür.
  /// Tanınmayan veya null değerler için varsayılan olarak [CourseStatus.pending] döner.
  static CourseStatus fromString(String? statusStr) {
    switch (statusStr) {
      case 'approved':
        return CourseStatus.approved;
      case 'rejected':
        return CourseStatus.rejected;
      case 'pending':
      default:
        return CourseStatus.pending;
    }
  }
}
