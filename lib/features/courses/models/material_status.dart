/// Ders materyalinin onay durumunu tanımlayan enum.
///
/// Firestore `courseMaterials` koleksiyonundaki `status` alanına karşılık gelir.
/// Kullanıcı materyal yükleme talebi gönderdiğinde varsayılan durum [pending] olur.
/// Admin onayından sonra [approved] veya [rejected] değerine geçer.
enum MaterialStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const MaterialStatus(this.value);

  /// String değerden [MaterialStatus] enum nesnesine dönüştürür.
  /// Tanınmayan veya null değerler için varsayılan olarak [MaterialStatus.pending] döner.
  static MaterialStatus fromString(String? statusStr) {
    switch (statusStr) {
      case 'approved':
        return MaterialStatus.approved;
      case 'rejected':
        return MaterialStatus.rejected;
      case 'pending':
      default:
        return MaterialStatus.pending;
    }
  }
}
