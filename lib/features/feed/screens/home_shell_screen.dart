import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../courses/screens/courses_screen.dart';
import '../../events/screens/events_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'create_post_screen.dart';
import 'feed_screen.dart';

/// Uygulamanın ana shell ekranı.
///
/// Bottom navigation aracılığıyla 5 sekme arasında geçiş sağlar:
/// - Akış (FeedScreen)
/// - Dersler (CoursesScreen)
/// - Paylaş (geçici placeholder)
/// - Etkinlikler (EventsScreen)
/// - Profil (ProfileScreen)
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  /// Aktif sekme indeksi. Başlangıçta Akış sekmesi (0) açıktır.
  int _currentIndex = 0;

  /// Her sekmeye karşılık gelen ekranlar listesi.
  final List<Widget> _screens = const [
    FeedScreen(),
    CoursesScreen(),
    _CreatePostPlaceholder(),
    EventsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed_outlined),
            activeIcon: Icon(Icons.dynamic_feed),
            label: 'Akış',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Dersler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Paylaş',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Etkinlikler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Geçici "Paylaş" sekmesi içeriği.
///
/// Post oluşturma ekranı ileride ayrı bir issue'da geliştirilecektir.
class _CreatePostPlaceholder extends StatelessWidget {
  const _CreatePostPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaş'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              size: 64,
              color: AppColors.primaryIndigo,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Paylaş',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Metin veya görselli post paylaş.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreatePostScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Post Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
