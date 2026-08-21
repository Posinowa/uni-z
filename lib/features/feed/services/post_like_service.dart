import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/firestore_service.dart';

/// Gönderi beğenme (like) ve beğeni kaldırma (unlike) işlemlerini yöneten servis sınıfı.
///
/// Firestore `postLikes` koleksiyonu (`{postId}_{userId}`) ve `posts` koleksiyonundaki `likeCount`
/// alanını atomik olarak transaction ile günceller.
///
/// Kurallar:
/// - Aynı kullanıcı aynı gönderiyi birden fazla kez beğenemez.
/// - Unlike yapıldığında `likeCount` 1 azalır ve asla negatif olmaz.
/// - `postLikes` koleksiyonunda doküman kimliği olarak `{postId}_{userId}` kullanılır.
class PostLikeService extends FirestoreService {
  /// [PostLikeService] oluşturur.
  ///
  /// Test edilebilirlik için opsiyonel [firestoreInstance] kabul eder.
  PostLikeService({super.firestoreInstance})
      : super(FirestoreCollections.postLikes);

  /// Doküman kimliğini oluşturur: `{postId}_{userId}`
  static String getLikeDocId(String postId, String userId) =>
      '${postId}_$userId';

  /// Kullanıcının belirtilen gönderiyi beğenip beğenmediğini kontrol eder.
  ///
  /// [postId] veya [userId] boş ise `false` döner.
  Future<bool> isPostLiked({
    required String postId,
    required String userId,
  }) async {
    if (postId.trim().isEmpty || userId.trim().isEmpty) {
      return false;
    }
    final docId = getLikeDocId(postId, userId);
    final docSnapshot = await collection.doc(docId).get();
    return docSnapshot.exists;
  }

  /// Kullanıcının belirtilen gönderideki beğeni durumunu anlık olarak dinler.
  ///
  /// [postId] veya [userId] boş ise `false` yayınlayan tekil bir stream döner.
  Stream<bool> watchIsPostLiked({
    required String postId,
    required String userId,
  }) {
    if (postId.trim().isEmpty || userId.trim().isEmpty) {
      return Stream.value(false);
    }
    final docId = getLikeDocId(postId, userId);
    return collection.doc(docId).snapshots().map((snapshot) => snapshot.exists);
  }

  /// Gönderiyi beğenir (Like).
  ///
  /// - `postLikes/{postId}_{userId}` dokümanı yoksa oluşturulur.
  /// - `posts/{postId}` belgesindeki `likeCount` değeri 1 artırılır.
  /// - Kullanıcı zaten beğenmişse işlem yinelenmez.
  Future<void> likePost({
    required String postId,
    required String userId,
  }) async {
    if (postId.trim().isEmpty || userId.trim().isEmpty) {
      throw ArgumentError('postId ve userId boş olamaz.');
    }

    final docId = getLikeDocId(postId, userId);
    final likeRef = collection.doc(docId);
    final postRef =
        firestore.collection(FirestoreCollections.posts).doc(postId);

    await firestore.runTransaction((transaction) async {
      final likeSnapshot = await transaction.get(likeRef);
      if (likeSnapshot.exists) {
        // Kullanıcı bu postu zaten beğenmiş, ikinci kez beğenemez.
        return;
      }

      final postSnapshot = await transaction.get(postRef);
      final currentLikeCount = postSnapshot.exists
          ? ((postSnapshot.data()?['likeCount'] as num?)?.toInt() ?? 0)
          : 0;

      transaction.set(likeRef, {
        'id': docId,
        'postId': postId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (postSnapshot.exists) {
        transaction.update(postRef, {
          'likeCount': currentLikeCount + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Gönderiden beğeniyi kaldırır (Unlike).
  ///
  /// - `postLikes/{postId}_{userId}` dokümanı silinir.
  /// - `posts/{postId}` belgesindeki `likeCount` 1 azaltılır (asla negatif olmaz).
  /// - Kullanıcı beğenmemişse işlem yapılmaz.
  Future<void> unlikePost({
    required String postId,
    required String userId,
  }) async {
    if (postId.trim().isEmpty || userId.trim().isEmpty) {
      throw ArgumentError('postId ve userId boş olamaz.');
    }

    final docId = getLikeDocId(postId, userId);
    final likeRef = collection.doc(docId);
    final postRef =
        firestore.collection(FirestoreCollections.posts).doc(postId);

    await firestore.runTransaction((transaction) async {
      final likeSnapshot = await transaction.get(likeRef);
      if (!likeSnapshot.exists) {
        // Kullanıcı bu postu beğenmemiş, silinecek beğeni yok.
        return;
      }

      final postSnapshot = await transaction.get(postRef);
      final currentLikeCount = postSnapshot.exists
          ? ((postSnapshot.data()?['likeCount'] as num?)?.toInt() ?? 0)
          : 0;

      transaction.delete(likeRef);

      if (postSnapshot.exists) {
        final newLikeCount = currentLikeCount > 0 ? currentLikeCount - 1 : 0;
        transaction.update(postRef, {
          'likeCount': newLikeCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Beğeni durumunu tersine çevirir (Toggle Like).
  ///
  /// Gönderi beğenilmişse beğeniyi kaldırır, beğenilmemişse beğenir.
  /// İşlem sonucunda güncel beğeni durumunu (`true`: beğenildi, `false`: beğeni kaldırıldı) döner.
  Future<bool> toggleLike({
    required String postId,
    required String userId,
  }) async {
    if (postId.trim().isEmpty || userId.trim().isEmpty) {
      throw ArgumentError('postId ve userId boş olamaz.');
    }

    final docId = getLikeDocId(postId, userId);
    final likeRef = collection.doc(docId);
    final postRef =
        firestore.collection(FirestoreCollections.posts).doc(postId);

    return await firestore.runTransaction<bool>((transaction) async {
      final likeSnapshot = await transaction.get(likeRef);
      final isCurrentlyLiked = likeSnapshot.exists;

      final postSnapshot = await transaction.get(postRef);
      final currentLikeCount = postSnapshot.exists
          ? ((postSnapshot.data()?['likeCount'] as num?)?.toInt() ?? 0)
          : 0;

      if (isCurrentlyLiked) {
        // Unlike işlemi
        transaction.delete(likeRef);

        if (postSnapshot.exists) {
          final newLikeCount = currentLikeCount > 0 ? currentLikeCount - 1 : 0;
          transaction.update(postRef, {
            'likeCount': newLikeCount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        return false;
      } else {
        // Like işlemi
        transaction.set(likeRef, {
          'id': docId,
          'postId': postId,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (postSnapshot.exists) {
          transaction.update(postRef, {
            'likeCount': currentLikeCount + 1,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        return true;
      }
    });
  }
}
