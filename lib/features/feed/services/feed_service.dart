
import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/firestore_service.dart';
import '../models/feed_post.dart';

/// Firestore `posts` koleksiyonu için CRUD servisi.
///
/// [FirestoreService] sınıfını extend ederek merkezi Firestore
/// instance'ını kullanır.
///
/// Bu servis UI katmanından doğrudan çağrılmaz — [FeedProvider]
/// veya ekran widget'ları üzerinden kullanılır.
class FeedService extends FirestoreService {
  FeedService({super.firestoreInstance})
      : super(FirestoreCollections.posts);

  /// Yeni bir post oluşturur ve Firestore'a kaydeder.
  ///
  /// [post] — Kaydedilecek [FeedPost] nesnesi.
  /// Firestore document ID otomatik oluşturulur ve post'a geri yazılır.
  ///
  /// Dönen değer: Oluşturulan document'ın ID'si.
  Future<String> createPost(FeedPost post) async {
    final docRef = collection.doc();
    final postWithId = post.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(postWithId.toMap());
    return docRef.id;
  }
}
