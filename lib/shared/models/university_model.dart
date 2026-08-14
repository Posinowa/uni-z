/// Firestore `universities` koleksiyonu için model sınıfı.
class UniversityModel {
  final String id;
  final String name;
  final String city;
  final bool isActive;

  const UniversityModel({
    required this.id,
    required this.name,
    required this.city,
    this.isActive = true,
  });

  /// Map (Firestore belge verisi) nesnesinden [UniversityModel] oluşturur.
  factory UniversityModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UniversityModel(
      id: id ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      city: map['city'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  /// [UniversityModel] nesnesini Firestore'a kaydedilecek Map formatına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'isActive': isActive,
    };
  }

  /// Mevcut nesnenin güncellenmiş kopyasını oluşturur.
  UniversityModel copyWith({
    String? id,
    String? name,
    String? city,
    bool? isActive,
  }) {
    return UniversityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      isActive: isActive ?? this.isActive,
    );
  }
}
