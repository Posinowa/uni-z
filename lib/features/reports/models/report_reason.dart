/// Rapor sebebini tanımlayan enum.
///
/// Firestore `reports` koleksiyonundaki `reason` alanına kaydedilecek
/// değer [value] alanıdır (İngilizce code, örn: inappropriate_content).
/// UI'da kullanıcıya gösterilecek Türkçe metin için [label] kullanılır.
enum ReportReason {
  inappropriateContent('inappropriate_content', 'Uygunsuz içerik'),
  spamMisleading('spam_misleading', 'Spam veya yanıltıcı'),
  hateSpeech('hate_speech', 'Nefret söylemi'),
  harassment('harassment', 'Taciz veya zorbalık'),
  copyrightViolation('copyright_violation', 'Telif hakkı ihlali'),
  other('other', 'Diğer');

  /// Firestore'a kaydedilen İngilizce code değeri.
  final String value;

  /// UI'da kullanıcıya gösterilen Türkçe etiket.
  final String label;

  const ReportReason(this.value, this.label);

  /// String code veya label değerinden [ReportReason] enum nesnesine dönüştürür.
  ///
  /// Bilinmeyen değerlerde [ReportReason.other] döner.
  static ReportReason fromString(String? val) {
    if (val == null || val.isEmpty) {
      return ReportReason.other;
    }
    for (final reason in ReportReason.values) {
      if (reason.value == val || reason.label == val) {
        return reason;
      }
    }
    return ReportReason.other;
  }
}
