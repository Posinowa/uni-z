/// Dersin onay durumunu tanımlayan enum.
///
/// Firestore `courses` koleksiyonundaki `status` alanına karşılık gelir.
/// Kullanıcı ders ekleme talebi gönderdiğinde varsayılan durum [pending] olur.
/// Admin onayından sonra [approved] veya [rejected] durumuna geçer.
enum CourseStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const CourseStatus(this.value);

  /// String değerden [CourseStatus] enum değerini çözer.
  ///
  /// Tanınmayan değerler için varsayılan olarak [CourseStatus.pending] döner.
  static CourseStatus fromString(String? value) {
    if (value == null) return CourseStatus.pending;
    return CourseStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CourseStatus.pending,
    );
  }
}
