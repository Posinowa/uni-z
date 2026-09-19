import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routing/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/notifications/services/in_app_notification_handler.dart';
import '../features/notifications/services/notification_service.dart';

/// Uygulama genelinde kullanılan GlobalKey tanımlamaları.
class AppKeys {
  AppKeys._();

  /// Global navigasyon anahtarı.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Global ScaffoldMessenger anahtarı.
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}

/// Foreground bildirimlerini dinleyip UI üzerinde gösteren wrapper widget.
///
/// Widget ağacında [MaterialApp.builder] veya herhangi bir üst widget seviyesinde
/// kullanılarak gelen bildirimleri SnackBar olarak ekrana basar.
class AppNotificationListener extends StatefulWidget {
  const AppNotificationListener({
    super.key,
    required this.child,
    this.asDialog = false,
  });

  /// Sarmalanan alt widget ağacı.
  final Widget child;

  /// Bildirimin SnackBar yerine Dialog olarak gösterilmesi isteniyorsa true verilir.
  final bool asDialog;

  @override
  State<AppNotificationListener> createState() =>
      _AppNotificationListenerState();
}

class _AppNotificationListenerState extends State<AppNotificationListener> {
  StreamSubscription<RemoteMessage>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToNotifications();
  }

  void _subscribeToNotifications() {
    _messageSubscription =
        NotificationService.instance.foregroundMessageStream.listen((message) {
      if (!mounted) return;

      if (widget.asDialog) {
        InAppNotificationHandler.show(
          context,
          message,
          asDialog: true,
          navigatorKey: AppKeys.navigatorKey,
        );
      } else {
        final messenger = AppKeys.scaffoldMessengerKey.currentState;
        if (messenger != null) {
          InAppNotificationHandler.showSnackBarWithMessenger(
            messenger,
            message,
            navigatorKey: AppKeys.navigatorKey,
          );
        } else {
          InAppNotificationHandler.show(
            context,
            message,
            asDialog: false,
            navigatorKey: AppKeys.navigatorKey,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Uni'z uygulamasının ana MaterialApp yapılandırması.
///
/// Tema, route ve foreground bildirim dinleyicisini içerir.
class UnizApp extends StatelessWidget {
  const UnizApp({
    super.key,
    this.onGenerateRoute,
    this.initialRoute = AppRoutes.splash,
  });

  /// Route üretici fonksiyon.
  final RouteFactory? onGenerateRoute;

  /// Başlangıç route'u.
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: "Uni'z",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: AppKeys.navigatorKey,
        scaffoldMessengerKey: AppKeys.scaffoldMessengerKey,
        initialRoute: initialRoute,
        onGenerateRoute: onGenerateRoute,
        builder: (context, child) {
          return AppNotificationListener(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
