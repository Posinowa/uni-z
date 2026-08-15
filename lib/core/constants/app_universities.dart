/// Uni'z uygulaması için Türkiye üniversitelerinin statik listesi.
///
/// Bu liste MVP aşamasında hardcoded tutulmaktadır.
/// İleride Firestore'dan çekilecek şekilde güncellenebilir.
///
/// Her üniversite bir [UniversityEntry] nesnesidir; `id` ve `name` içerir.
/// `id` değerleri Firestore'daki `universities/{universityId}` ile uyumludur.
library;

/// Tek bir üniversite kaydını temsil eder.
class UniversityEntry {
  const UniversityEntry({
    required this.id,
    required this.name,
  });

  /// Firestore'daki `universities` koleksiyonundaki belge kimliği.
  final String id;

  /// Kullanıcıya gösterilecek üniversite adı.
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniversityEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Türkiye devlet ve vakıf üniversitelerinden oluşan başlangıç listesi.
///
/// Kapsam dışı: tüm üniversiteler eksiksiz girilmez — MVP için yeterli sayıda.
const List<UniversityEntry> kTurkishUniversities = [
  UniversityEntry(id: 'itu', name: 'İstanbul Teknik Üniversitesi'),
  UniversityEntry(id: 'boun', name: 'Boğaziçi Üniversitesi'),
  UniversityEntry(id: 'metu', name: 'Orta Doğu Teknik Üniversitesi'),
  UniversityEntry(id: 'ankara-uni', name: 'Ankara Üniversitesi'),
  UniversityEntry(id: 'istanbul-uni', name: 'İstanbul Üniversitesi'),
  UniversityEntry(id: 'hacettepe', name: 'Hacettepe Üniversitesi'),
  UniversityEntry(id: 'ege', name: 'Ege Üniversitesi'),
  UniversityEntry(id: 'deu', name: 'Dokuz Eylül Üniversitesi'),
  UniversityEntry(id: 'marmara', name: 'Marmara Üniversitesi'),
  UniversityEntry(id: 'gazi', name: 'Gazi Üniversitesi'),
  UniversityEntry(id: 'ostim-teknik', name: 'Ostim Teknik Üniversitesi'),
  UniversityEntry(id: 'koc', name: 'Koç Üniversitesi'),
  UniversityEntry(id: 'sabanci', name: 'Sabancı Üniversitesi'),
  UniversityEntry(id: 'ytu', name: 'Yıldız Teknik Üniversitesi'),
  UniversityEntry(id: 'bau', name: 'Bahçeşehir Üniversitesi'),
  UniversityEntry(id: 'ataturk-uni', name: 'Atatürk Üniversitesi'),
  UniversityEntry(id: 'erciyes', name: 'Erciyes Üniversitesi'),
  UniversityEntry(id: 'selcuk', name: 'Selçuk Üniversitesi'),
  UniversityEntry(id: 'uludag', name: 'Bursa Uludağ Üniversitesi'),
  UniversityEntry(id: 'cukurova', name: 'Çukurova Üniversitesi'),
  UniversityEntry(id: 'karadeniz-teknik', name: 'Karadeniz Teknik Üniversitesi'),
  UniversityEntry(id: 'firat', name: 'Fırat Üniversitesi'),
  UniversityEntry(id: 'pamukkale', name: 'Pamukkale Üniversitesi'),
  UniversityEntry(id: 'akdeniz', name: 'Akdeniz Üniversitesi'),
  UniversityEntry(id: 'ihsan-dogramaci-bilkent', name: 'İhsan Doğramacı Bilkent Üniversitesi'),
];
