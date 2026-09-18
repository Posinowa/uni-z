/// Etkinliğin onay durumunu tanımlayan enum.
///
/// Firestore `events` koleksiyonundaki `status` alanına karşılık gelir.
enum EventStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const EventStatus(this.value);

  /// String değerden [EventStatus] enum nesnesine dönüştürür.
  /// Tanınmayan veya null değerler için varsayılan olarak [EventStatus.pending] döner.
  static EventStatus fromString(String? statusStr) {
    switch (statusStr) {
      case 'approved':
        return EventStatus.approved;
      case 'rejected':
        return EventStatus.rejected;
      case 'pending':
      default:
        return EventStatus.pending;
    }
  }
}
