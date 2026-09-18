import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/course_card.dart';
import '../widgets/course_empty_state.dart';
import '../widgets/course_search_bar.dart';

/// Kullanıcının üniversitesindeki dersleri görüntüleyebildiği ve
/// arama yapabildiği ders listesi ekranı.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// Örnek ders listesi (Kapsam dışı gereği Firestore bağlantısı bulunmamaktadır).
  final List<_CourseItem> _allCourses = const [
    _CourseItem(
      courseCode: 'CS101',
      courseName: 'Bilgisayar Mühendisliğine Giriş',
      departmentName: 'Bilgisayar Mühendisliği',
      materialCount: 14,
    ),
    _CourseItem(
      courseCode: 'MATH101',
      courseName: 'Kalkülüs I',
      departmentName: 'Matematik',
      materialCount: 22,
    ),
    _CourseItem(
      courseCode: 'PHYS101',
      courseName: 'Genel Fizik I',
      departmentName: 'Fizik',
      materialCount: 9,
    ),
    _CourseItem(
      courseCode: 'CS201',
      courseName: 'Veri Yapıları ve Algoritmalar',
      departmentName: 'Bilgisayar Mühendisliği',
      materialCount: 18,
    ),
    _CourseItem(
      courseCode: 'EE201',
      courseName: 'Elektrik Devre Temelleri',
      departmentName: 'Elektrik-Elektronik Mühendisliği',
      materialCount: 7,
    ),
    _CourseItem(
      courseCode: 'ENG101',
      courseName: 'Akademik İngilizce I',
      departmentName: 'Yabancı Diller',
      materialCount: 11,
    ),
    _CourseItem(
      courseCode: 'IE102',
      courseName: 'Endüstri Mühendisliğine Giriş',
      departmentName: 'Endüstri Mühendisliği',
      materialCount: 5,
    ),
  ];

  String _searchQuery = '';

  List<_CourseItem> get _filteredCourses {
    if (_searchQuery.trim().isEmpty) {
      return _allCourses;
    }

    final query = _searchQuery.toLowerCase();
    return _allCourses.where((course) {
      return course.courseCode.toLowerCase().contains(query) ||
          course.courseName.toLowerCase().contains(query) ||
          course.departmentName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onAddCoursePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ders ekleme özelliği yakında kullanıma açılacaktır.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courses = _filteredCourses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dersler'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddCoursePressed,
        icon: const Icon(Icons.add),
        label: const Text('Ders Ekle'),
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ─── Arama Çubuğu ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: CourseSearchBar(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          ),

          // ─── Ders Listesi veya Boş Durum ────────────────────────────
          Expanded(
            child: courses.isEmpty
                ? CourseEmptyState(
                    title: 'Ders Bulunamadı',
                    description: _searchQuery.isNotEmpty
                        ? '"$_searchQuery" aramasına uygun ders bulunamadı.'
                        : 'Henüz kayıtlı bir ders bulunmamaktadır.',
                    actionText: _searchQuery.isNotEmpty ? 'Aramayı Temizle' : null,
                    onActionPressed: _searchQuery.isNotEmpty
                        ? () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          }
                        : null,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxxl * 2, // FAB alanı için ekstra alt boşluk
                    ),
                    itemCount: courses.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = courses[index];
                      return CourseCard(
                        courseCode: item.courseCode,
                        courseName: item.courseName,
                        departmentName: item.departmentName,
                        materialCount: item.materialCount,
                        onTap: () {
                          // Kapsam dışı: Ders detay yok.
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// UI gösterimi için dahili ders modeli.
class _CourseItem {
  const _CourseItem({
    required this.courseCode,
    required this.courseName,
    required this.departmentName,
    required this.materialCount,
  });

  final String courseCode;
  final String courseName;
  final String departmentName;
  final int materialCount;
}
