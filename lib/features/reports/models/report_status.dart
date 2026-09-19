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
  ///
  /// Bilinmeyen veya null değerlerde [ReportStatus.open] döner.
  static ReportStatus fromString(String? statusStr) {
    switch (statusStr) {
      case 'open':
        return ReportStatus.open;
      case 'reviewed':
        return ReportStatus.reviewed;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      case null:
        return ReportStatus.open;
      default:
        return ReportStatus.open;
    }
  }
}
