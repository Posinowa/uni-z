import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../widgets/in_app_notification_snackbar.dart';
import '../widgets/notification_dialog.dart';

/// Foreground bildirimlerini yakalayıp UI üzerinde gösteren ve yönlendirmeyi yöneten kontrolcü.
///
/// Mesaj içeriğindeki eksik/boş verileri güvenle işler, uygulamanın çökmesini engeller.
/// Tıklama anında kullanıcıyı [AppRoutes.home] ekranına yönlendirir.
class InAppNotificationHandler {
  InAppNotificationHandler._();

  /// [RemoteMessage] nesnesinden başlığı güvenle çeker.
  static String extractTitle(RemoteMessage message) {
    try {
      final notifTitle = message.notification?.title?.trim();
      if (notifTitle != null && notifTitle.isNotEmpty) {
        return notifTitle;
      }

      final dataTitle = message.data['title']?.toString().trim();
      if (dataTitle != null && dataTitle.isNotEmpty) {
        return dataTitle;
      }
    } catch (_) {}

    return 'Yeni Bildirim';
  }

  /// [RemoteMessage] nesnesinden gövde metnini güvenle çeker.
  static String? extractBody(RemoteMessage message) {
    try {
      final notifBody = message.notification?.body?.trim();
      if (notifBody != null && notifBody.isNotEmpty) {
        return notifBody;
      }

      final dataBody = message.data['body']?.toString().trim();
      if (dataBody != null && dataBody.isNotEmpty) {
        return dataBody;
      }
    } catch (_) {}

    return null;
  }

  /// Bildirime tıklandığında ana sayfaya yönlendirir.
  static void navigateToHome({
    BuildContext? context,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    try {
      if (navigatorKey?.currentState != null) {
        navigatorKey!.currentState!.pushNamed(AppRoutes.home);
        return;
      }

      if (context != null && context.mounted) {
        Navigator.of(context).pushNamed(AppRoutes.home);
      }
    } catch (_) {
      // Navigasyon hatası durumunda çökme önlenir.
    }
  }

  /// Gelen mesajı [ScaffoldMessengerState] aracılığıyla SnackBar olarak gösterir.
  static void showSnackBarWithMessenger(
    ScaffoldMessengerState messenger,
    RemoteMessage message, {
    GlobalKey<NavigatorState>? navigatorKey,
    VoidCallback? customOnTap,
  }) {
    try {
      final title = extractTitle(message);
      final body = extractBody(message);

      InAppNotificationSnackBar.showWithMessenger(
        messenger,
        title: title,
        body: body,
        onTap: () {
          if (customOnTap != null) {
            customOnTap();
          } else {
            navigateToHome(navigatorKey: navigatorKey);
          }
        },
      );
    } catch (_) {
      // Hata durumunda uygulama çökmez.
    }
  }

  /// Gelen mesajı [BuildContext] aracılığıyla SnackBar veya Dialog olarak gösterir.
  static void show(
    BuildContext context,
    RemoteMessage message, {
    bool asDialog = false,
    GlobalKey<NavigatorState>? navigatorKey,
    VoidCallback? customOnTap,
  }) {
    if (!context.mounted) return;

    try {
      final title = extractTitle(message);
      final body = extractBody(message);

      void handleTap() {
        if (customOnTap != null) {
          customOnTap();
        } else {
          navigateToHome(context: context, navigatorKey: navigatorKey);
        }
      }

      if (asDialog) {
        NotificationDialog.show(
          context,
          title: title,
          body: body,
          onTap: handleTap,
        );
      } else {
        InAppNotificationSnackBar.show(
          context,
          title: title,
          body: body,
          onTap: handleTap,
        );
      }
    } catch (_) {
      // Hata durumunda uygulama çökmez.
    }
  }
}
