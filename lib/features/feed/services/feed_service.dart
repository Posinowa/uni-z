import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/firestore_service.dart';
import '../models/feed_post.dart';
import '../models/post_status.dart';

/// Firestore `posts` koleksiyonu üzerindeki okuma işlemlerini yöneten servis sınıfı.
///
/// [FirestoreService] sınıfını extend eder ve `posts` koleksiyonuna bağlanır.
class FeedService extends FirestoreService {
  /// Yeni bir [FeedService] oluşturur.
  ///
  /// Opsiyonel [firestoreInstance] parametresi test edilebilirlik için kullanılır.
  FeedService({FirebaseFirestore? firestoreInstance})
      : super(
          FirestoreCollections.posts,
          firestoreInstance: firestoreInstance,
        );

  /// Yayında olan gönderileri `createdAt` alanına göre azalan sırada dinler.
  ///
  /// Sadece `status == published` olan gönderiler döner.
  Stream<List<FeedPost>> watchPublishedPosts() {
    return collection
        .where('status', isEqualTo: PostStatus.published.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedPost.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }
}
