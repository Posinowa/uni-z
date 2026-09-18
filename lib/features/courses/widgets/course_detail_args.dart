/// Ders detay ekranına rota üzerinden veya doğrudan aktarılan verileri temsil eder.
///
/// Junior geliştiriciler için:
/// Bu sınıf, bir dersin kodunu, adını, ait olduğu üniversiteyi ve bölümü,
/// ayrıca açıklamasını tek bir nesnede toplar.
class CourseDetailArgs {
  /// Firestore'daki ders belgesinin kimliği (opsiyonel).
  final String? courseId;

  /// Dersin kodu (örn: CENG101, MAT101).
  final String courseCode;

  /// Dersin adı (örn: Bilgisayar Mühendisliğine Giriş).
  final String courseName;

  /// Ders hakkında kısa açıklama (opsiyonel).
  final String? description;

  /// Dersin ait olduğu üniversitenin adı.
  final String universityName;

  /// Dersin ait olduğu bölümün adı.
  final String departmentName;

  const CourseDetailArgs({
    this.courseId,
    required this.courseCode,
    required this.courseName,
    this.description,
    required this.universityName,
    required this.departmentName,
  });

  /// Haritadan (Map) [CourseDetailArgs] oluşturur (Route arguments için).
  factory CourseDetailArgs.fromMap(Map<String, dynamic> map) {
    return CourseDetailArgs(
      courseId: map['courseId'] as String?,
      courseCode: map['courseCode'] as String? ?? '',
      courseName: map['courseName'] as String? ?? '',
      description: map['description'] as String?,
      universityName: map['universityName'] as String? ?? '',
      departmentName: map['departmentName'] as String? ?? '',
    );
  }

  /// [CourseDetailArgs] nesnesini Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseCode': courseCode,
      'courseName': courseName,
      'description': description,
      'universityName': universityName,
      'departmentName': departmentName,
    };
  }

  /// Varsayılan örnek ders verisi (argümansız açılışlarda veya önizlemelerde kullanılır).
  factory CourseDetailArgs.defaultCourse() {
    return const CourseDetailArgs(
      courseId: 'demo-course-1',
      courseCode: 'CENG101',
      courseName: 'Bilgisayar Mühendisliğine Giriş',
      description:
          'Bu ders, bilgisayar bilimleri ve mühendisliğinin temel kavramlarını, problem çözme yaklaşımlarını ve algoritma mantığını kapsar.',
      universityName: 'Orta Doğu Teknik Üniversitesi',
      departmentName: 'Bilgisayar Mühendisliği',
    );
  }
}
