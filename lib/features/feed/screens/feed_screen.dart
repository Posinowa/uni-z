import 'package:flutter/material.dart';

import '../../../shared/widgets/states/states.dart';
import '../models/feed_post.dart';
import '../services/feed_service.dart';
import '../widgets/post_card.dart';

/// Ana akış ekranı.
///
/// Firestore'dan yayında olan gönderileri `createdAt` azalan sırada dinler
/// ve her gönderiyi [PostCard] widget'ı ile listeler.
///
/// Üç farklı durum yönetir:
/// - **Loading:** Veri beklenirken spinner gösterir.
/// - **Empty:** Hiç gönderi yoksa bilgilendirme mesajı gösterir.
/// - **Error:** Firestore hatasında hata mesajı ve tekrar dene butonu gösterir.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  /// Firestore `posts` koleksiyonu ile iletişim kuran servis.
  final FeedService _feedService = FeedService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uni'z Akış"),
      ),
      body: StreamBuilder<List<FeedPost>>(
        stream: _feedService.watchPublishedPosts(),
        builder: (context, snapshot) {
          // ─── Hata Durumu ──────────────────────────────────────
          if (snapshot.hasError) {
            return AppErrorState(
              title: 'Gönderiler yüklenemedi',
              message: 'Bir hata oluştu. Lütfen tekrar deneyin.',
              onRetry: () {
                // StreamBuilder yeniden build olması için setState çağırılır.
                setState(() {});
              },
            );
          }

          // ─── Yükleniyor Durumu ────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }

          final posts = snapshot.data ?? [];

          // ─── Boş Durum ────────────────────────────────────────
          if (posts.isEmpty) {
            return const AppEmptyState(
              icon: Icons.dynamic_feed_outlined,
              title: 'Henüz gönderi yok',
              description: 'İlk paylaşımı sen yap!',
            );
          }

          // ─── Gönderi Listesi ──────────────────────────────────
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(post: post);
            },
          );
        },
      ),
    );
  }
}
