import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/routing/app_router.dart';
import 'features/notifications/services/notification_service.dart';
import 'firebase_options.dart';

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

  runApp(
    UnizApp(
      onGenerateRoute: AppRouter.onGenerateRoute,
    ),
  );
}
