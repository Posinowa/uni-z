/// Raporun inceleme durumunu tanımlayan enum.
///
/// Firestore `reports` koleksiyonundaki `status` alanına karşılık gelir.
enum ReportStatus {
  open('open'),
  reviewed('reviewed'),
  resolved('resolved'),
  rejected('rejected');

  final String value;
  const ReportStatus(this.value);

  /// String değerden [ReportStatus] enum nesnesine dönüştürür.
  /// Tanınmayan veya null değerler için varsayılan olarak [ReportStatus.open] döner.
  static ReportStatus fromString(String? statusStr) {
    switch (statusStr) {
      case 'reviewed':
        return ReportStatus.reviewed;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      case 'open':
      default:
        return ReportStatus.open;
    }
  }
}
