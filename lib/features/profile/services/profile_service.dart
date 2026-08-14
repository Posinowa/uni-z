import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/firestore_service.dart';
import '../models/user_profile.dart';

/// Firestore `users` koleksiyonu üzerindeki kullanıcı profili CRUD ve dinleme işlemlerini yöneten servis sınıfı.
///
/// UI bağımlılığı ve Auth mantığı içermez.
/// Hata durumlarında Firestore istisnaları üst katmana fırlatılır.
class ProfileService extends FirestoreService {
  /// [ProfileService] oluşturur.
  ///
  /// Testlerde sahte/mock instance verebilmek için opsiyonel [firestoreInstance] kabul eder.
  ProfileService({super.firestoreInstance}) : super(FirestoreCollections.users);

  /// Yeni kullanıcı profilini Firestore `users` koleksiyonuna kaydeder.
  ///
  /// [profile] nesnesinin `id` değeri belge kimliği (document ID) olarak kullanılır.
  /// Boş `id` durumunda [ArgumentError] fırlatır.
  /// İşlem sırasında hata oluşursa [FirebaseException] fırlatır.
  Future<void> createUserProfile(UserProfile profile) async {
    if (profile.id.trim().isEmpty) {
      throw ArgumentError('Kullanıcı kimliği (id) boş olamaz.');
    }
    await collection.doc(profile.id).set(profile.toMap());
  }

  /// Belirtilen [userId] kimliğine sahip kullanıcı profilini Firestore'dan getirir.
  ///
  /// [userId] boş veya geçersizse `null` döner.
  /// Belge bulunamazsa veya veri `null` ise `null` döner.
  /// İşlem sırasında hata oluşursa [FirebaseException] fırlatır.
  Future<UserProfile?> getUserProfile(String userId) async {
    if (userId.trim().isEmpty) {
      return null;
    }
    final snapshot = await collection.doc(userId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return UserProfile.fromMap(snapshot.data()!, id: snapshot.id);
  }

  /// Mevcut kullanıcı profilini Firestore'da günceller.
  ///
  /// [profile] nesnesinin `id` değeriyle eşleşen belge güncellenir.
  /// Boş `id` durumunda [ArgumentError] fırlatır.
  /// İşlem sırasında hata oluşursa [FirebaseException] fırlatır.
  Future<void> updateUserProfile(UserProfile profile) async {
    if (profile.id.trim().isEmpty) {
      throw ArgumentError('Kullanıcı kimliği (id) boş olamaz.');
    }
    await collection.doc(profile.id).update(profile.toMap());
  }

  /// Belirtilen [userId] kimliğine sahip kullanıcının profilini anlık olarak dinler.
  ///
  /// [userId] boş ise anında `null` yayınlayan bir stream döner.
  /// Profil değiştiğinde veya yeni veri geldiğinde güncel [UserProfile] nesnesi yayınlanır.
  /// Belge yoksa veya veri `null` ise `null` yayınlar.
  Stream<UserProfile?> watchUserProfile(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value(null);
    }
    return collection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return UserProfile.fromMap(snapshot.data()!, id: snapshot.id);
    });
  }
}
