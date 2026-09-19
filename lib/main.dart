import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/notifications/services/notification_service.dart';
import 'firebase_options.dart';

/// Snackbar gösterimi için global ScaffoldMessenger anahtarı.
///
/// Foreground bildirim geldiğinde herhangi bir ekrandan
/// snackbar gösterebilmek için kullanılır.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Çevre değişkenlerini yükle — .env yoksa .env.example'a fallback yap
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    await dotenv.load(fileName: '.env.example');
  }

  // Firebase başlat — initialize olmadan uygulama başlamamalı
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM bildirim altyapısını başlat
  await NotificationService.instance.initialize();

  // Foreground bildirim geldiğinde snackbar göster
  NotificationService.instance.onForegroundMessage = (message) {
    final notification = message.notification;
    if (notification == null) return;

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          notification.title ?? notification.body ?? 'Yeni bildirim',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  };

  runApp(const UnizMobileApp());
}

class UnizMobileApp extends StatelessWidget {
  const UnizMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: "Uni'z",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        scaffoldMessengerKey: scaffoldMessengerKey,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}

