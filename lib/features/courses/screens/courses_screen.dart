import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/states/states.dart';
import '../../profile/services/profile_service.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';
import '../widgets/course_card.dart';
import '../widgets/course_detail_args.dart';
import '../widgets/course_search_bar.dart';
import 'course_detail_screen.dart';
import 'suggest_course_screen.dart';

/// Kullanıcının kayıtlı olduğu üniversiteye ait onaylanmış dersleri listeleyen ekran.
///
/// Firestore üzerinden `CourseService.watchApprovedCourses` stream'ine bağlanır.
/// - Yükleme durumu için [AppLoadingView]
/// - Hata durumu için [AppErrorState]
/// - Boş liste veya sonuç bulunamama durumu için [AppEmptyState]
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({
    this.courseService,
    this.profileService,
    this.authInstance,
    super.key,
  });

  final CourseService? courseService;
  final ProfileService? profileService;
  final FirebaseAuth? authInstance;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late final CourseService _courseService;
  late final ProfileService _profileService;
  late final FirebaseAuth _auth;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isLoadingProfile = true;
  String? _profileErrorMessage;
  String? _universityId;
  Stream<List<CourseModel>>? _coursesStream;

  @override
  void initState() {
    super.initState();
    _courseService = widget.courseService ?? CourseService();
    _profileService = widget.profileService ?? ProfileService();
    _auth = widget.authInstance ?? FirebaseAuth.instance;

    _loadUserProfileAndCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Kullanıcının oturum ve profil bilgilerinden [universityId] değerini alır
  /// ve [CourseService.watchApprovedCourses] stream'ini başlatır.
  Future<void> _loadUserProfileAndCourses() async {
    setState(() {
      _isLoadingProfile = true;
      _profileErrorMessage = null;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoadingProfile = false;
          _profileErrorMessage =
              'Dersleri görüntülemek için oturum açmış olmalısınız.';
        });
        return;
      }

      final profile = await _profileService.getUserProfile(currentUser.uid);
      final universityId = profile?.universityId;

      if (universityId == null || universityId.trim().isEmpty) {
        setState(() {
          _isLoadingProfile = false;
          _profileErrorMessage =
              'Profilinizde üniversite bilgisi bulunamadı. Lütfen profilinizi tamamlayın.';
        });
        return;
      }

      setState(() {
        _universityId = universityId;
        _isLoadingProfile = false;
        _coursesStream = _courseService.watchApprovedCourses(
          universityId: universityId,
        );
      });
    } catch (_) {
      setState(() {
        _isLoadingProfile = false;
        _profileErrorMessage =
            'Kullanıcı bilgileri yüklenirken bir hata oluştu. Lütfen tekrar deneyin.';
      });
    }
  }

  void _retryStream() {
    if (_universityId != null) {
      setState(() {
        _coursesStream = _courseService.watchApprovedCourses(
          universityId: _universityId!,
        );
      });
    } else {
      _loadUserProfileAndCourses();
    }
  }

  void _onAddCoursePressed() {
    Navigator.push(context, SuggestCourseScreen.route());
  }

  List<CourseModel> _filterCoursesLocally(List<CourseModel> courses) {
    if (_searchQuery.trim().isEmpty) {
      return courses;
    }

    final query = _searchQuery.toLowerCase();
    return courses.where((course) {
      final codeMatches = course.courseCode.toLowerCase().contains(query);
      final nameMatches = course.courseName.toLowerCase().contains(query);
      final deptMatches =
          (course.departmentName ?? course.departmentId).toLowerCase().contains(query);
      return codeMatches || nameMatches || deptMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                setState(() => _searchQuery = val);
              },
              onClear: () {
                setState(() => _searchQuery = '');
              },
            ),
          ),

          // ─── Ders Listesi / Yükleniyor / Hata / Boş Durumları ────────
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // 1. Profil / Üniversite bilgisi yükleniyor durumu
    if (_isLoadingProfile) {
      return const AppLoadingView();
    }

    // 2. Profil okunamadı veya kullanıcı oturum açmamış durumu
    if (_profileErrorMessage != null) {
      return AppErrorState(
        title: 'Bilgiler Yüklenemedi',
        message: _profileErrorMessage!,
        onRetry: _loadUserProfileAndCourses,
      );
    }

    // 3. Firestore stream dinleniyor
    return StreamBuilder<List<CourseModel>>(
      stream: _coursesStream,
      builder: (context, snapshot) {
        // Yükleniyor durumu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingView();
        }

        // Hata durumu
        if (snapshot.hasError) {
          return AppErrorState(
            title: 'Dersler Yüklenemedi',
            message: 'Ders listesi alınırken bir hata oluştu. Lütfen tekrar deneyin.',
            onRetry: _retryStream,
          );
        }

        final allApprovedCourses = snapshot.data ?? [];

        // Üniversiteye ait hiç onaylı ders yoksa
        if (allApprovedCourses.isEmpty) {
          return AppEmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Henüz Ders Eklenmemiş',
            description:
                'Üniversitenize ait onaylanmış bir ders bulunmamaktadır. İlk dersi sen önererek başlayabilirsin.',
            actionText: 'Ders Öner',
            actionIcon: Icons.add,
            onActionPressed: _onAddCoursePressed,
          );
        }

        // Arama sorgusuna göre lokal filtreleme
        final filteredCourses = _filterCoursesLocally(allApprovedCourses);

        // Arama sonucunda ders bulunamadıysa
        if (filteredCourses.isEmpty) {
          return AppEmptyState(
            icon: Icons.search_off_rounded,
            title: 'Ders Bulunamadı',
            description: '"$_searchQuery" aramasına uygun ders bulunamadı.',
            actionText: 'Aramayı Temizle',
            actionIcon: Icons.clear,
            onActionPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          );
        }

        // Onaylanmış ders listesi
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxxl * 2, // FAB için alt boşluk
          ),
          itemCount: filteredCourses.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final course = filteredCourses[index];
            final departmentDisplay = course.departmentName != null &&
                    course.departmentName!.trim().isNotEmpty
                ? course.departmentName!
                : course.departmentId;

            return CourseCard(
              courseCode: course.courseCode,
              courseName: course.courseName,
              departmentName: departmentDisplay,
              materialCount: 0, // Placeholder
              onTap: () {
                Navigator.push(
                  context,
                  CourseDetailScreen.route(
                    args: CourseDetailArgs(
                      courseId: course.id,
                      courseCode: course.courseCode,
                      courseName: course.courseName,
                      description: course.description,
                      universityName: course.universityName ?? '',
                      departmentName: departmentDisplay,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
