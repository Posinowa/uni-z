import 'package:flutter/material.dart';

import '../../courses/screens/courses_screen.dart';
import '../../events/screens/events_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'create_text_post_screen.dart';
import 'feed_screen.dart';

/// Uygulamanın ana shell ekranı.
///
/// Bottom navigation aracılığıyla 5 sekme arasında geçiş sağlar:
/// - Akış (FeedScreen)
/// - Dersler (CoursesScreen)
/// - Paylaş (CreateTextPostScreen)
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
  List<Widget> get _screens => [
        const FeedScreen(),
        const CoursesScreen(),
        CreateTextPostScreen(
          onPostCreated: () {
            setState(() => _currentIndex = 0);
          },
        ),
        const EventsScreen(),
        const ProfileScreen(),
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
