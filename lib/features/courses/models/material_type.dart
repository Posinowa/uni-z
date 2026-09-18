/// Ders materyalinin türünü tanımlayan enum.
///
/// Firestore `courseMaterials` koleksiyonundaki `type` alanına karşılık gelir.
enum MaterialType {
  lectureNote('lecture_note'),
  pastExam('past_exam'),
  summary('summary'),
  other('other');

  final String value;
  const MaterialType(this.value);

  /// String değerden [MaterialType] enum nesnesine dönüştürür.
  /// Tanınmayan veya null değerler için varsayılan olarak [MaterialType.other] döner.
  static MaterialType fromString(String? typeStr) {
    switch (typeStr) {
      case 'lecture_note':
        return MaterialType.lectureNote;
      case 'past_exam':
        return MaterialType.pastExam;
      case 'summary':
        return MaterialType.summary;
      case 'other':
      default:
        return MaterialType.other;
    }
  }
}
