import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore işlemleri için temel servis sınıfı.
///
/// Tüm Firestore servisleri bu sınıfı extend ederek kullanmalıdır.
/// Firestore instance merkezi olarak bu sınıftan sağlanır.
///
/// Bu sınıf doğrudan kullanılmaz; alt sınıflar tarafından extend edilir.
///
/// Örnek:
/// ```dart
/// class UserService extends FirestoreService {
///   UserService() : super(FirestoreCollections.users);
///
///   // CRUD metotları burada tanımlanır.
/// }
/// ```
class FirestoreService {
  /// Merkezi Firestore instance — tüm alt sınıflar bunu kullanır.
  final FirebaseFirestore firestore;

  /// Bu servisin çalıştığı collection'ın referansı.
  final CollectionReference<Map<String, dynamic>> collection;

  /// [collectionPath] — Firestore'daki collection adı.
  /// [FirestoreCollections] sabitlerinden alınmalıdır.
  ///
  /// Opsiyonel [firestoreInstance] parametresi test edilebilirlik için
  /// dependency injection'a olanak tanır.
  FirestoreService(
    String collectionPath, {
    FirebaseFirestore? firestoreInstance,
  })  : firestore = firestoreInstance ?? FirebaseFirestore.instance,
        collection = (firestoreInstance ?? FirebaseFirestore.instance)
            .collection(collectionPath);
}
