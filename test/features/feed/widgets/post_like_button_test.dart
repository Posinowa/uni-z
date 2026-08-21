import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniz_mobile/features/feed/services/post_like_service.dart';
import 'package:uniz_mobile/features/feed/widgets/post_like_button.dart';

class MockPostLikeService extends Fake implements PostLikeService {
  bool isLikedResult = false;
  bool toggleShouldSucceed = true;
  int toggleCallCount = 0;

  @override
  Future<bool> isPostLiked({
    required String postId,
    required String userId,
  }) async {
    return isLikedResult;
  }

  @override
  Future<bool> toggleLike({
    required String postId,
    required String userId,
  }) async {
    toggleCallCount++;
    if (!toggleShouldSucceed) {
      throw Exception('Firestore error');
    }
    isLikedResult = !isLikedResult;
    return isLikedResult;
  }
}

void main() {
  group('PostLikeButton Widget Testleri', () {
    late MockPostLikeService mockService;

    setUp(() {
      mockService = MockPostLikeService();
    });

    testWidgets('Başlangıçta beğenilmemişse boş kalp ve doğru sayı gösterilir',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostLikeButton(
              postId: 'post_1',
              userId: 'user_1',
              initialLikeCount: 10,
              initialIsLiked: false,
              postLikeService: mockService,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('Başlangıçta beğenilmişse dolu kalp ve kırmızı renk gösterilir',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostLikeButton(
              postId: 'post_1',
              userId: 'user_1',
              initialLikeCount: 10,
              initialIsLiked: true,
              postLikeService: mockService,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('Butona tıklandığında anlık olarak beğeni sayısı artar ve ikon değişir',
        (tester) async {
      int? changedCount;
      bool? changedIsLiked;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostLikeButton(
              postId: 'post_1',
              userId: 'user_1',
              initialLikeCount: 10,
              initialIsLiked: false,
              postLikeService: mockService,
              onLikeChanged: (isLiked, count) {
                changedIsLiked = isLiked;
                changedCount = count;
              },
            ),
          ),
        ),
      );

      // Tıklanır
      await tester.tap(find.byType(PostLikeButton));
      await tester.pumpAndSettle();

      expect(mockService.toggleCallCount, 1);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(changedIsLiked, isTrue);
      expect(changedCount, 11);

      // İkinci kez tıklanır (unlike)
      await tester.tap(find.byType(PostLikeButton));
      await tester.pumpAndSettle();

      expect(mockService.toggleCallCount, 2);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(changedIsLiked, isFalse);
      expect(changedCount, 10);
    });

    testWidgets('Giriş yapmamış kullanıcıda uyarı SnackBar gösterilir',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostLikeButton(
              postId: 'post_1',
              userId: '', // Boş kullanıcı
              initialLikeCount: 5,
              initialIsLiked: false,
              postLikeService: mockService,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PostLikeButton));
      await tester.pump();

      expect(find.text('Beğenmek için giriş yapmalısınız.'), findsOneWidget);
      expect(mockService.toggleCallCount, 0);
    });

    testWidgets('İşlem sırasında hata oluşursa UI önceki duruma geri döner',
        (tester) async {
      mockService.toggleShouldSucceed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostLikeButton(
              postId: 'post_1',
              userId: 'user_1',
              initialLikeCount: 10,
              initialIsLiked: false,
              postLikeService: mockService,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PostLikeButton));
      await tester.pumpAndSettle();

      // Hata sonrası durum geri alınmış olmalı (10 ve favorite_border)
      expect(find.text('10'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('Beğeni işlemi gerçekleştirilemedi.'), findsOneWidget);
    });
  });
}
