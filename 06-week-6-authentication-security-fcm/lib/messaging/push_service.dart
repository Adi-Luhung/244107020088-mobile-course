import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
}

class PushService {
  PushService();

  final _local = FlutterLocalNotificationsPlugin();
  String? pendingDeepLink;

  Future<bool> requestNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('FCM requestPermission error: $e');
      return false;
    }
  }

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    
    await _local.initialize(
      settings: const InitializationSettings(
        android: android, 
        iOS: ios,
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) pendingDeepLink = response.payload;
      },
    );
  }

  Future<void> initFcmToken({required Future<void> Function(String token) onToken}) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await onToken(token);

      FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
      
      await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
    } catch (e) {
      debugPrint('FCM initFcmToken error: $e');
    }
  }

  void listenForeground() {
    try {
      FirebaseMessaging.onMessage.listen((message) async {
        final route = message.data['route'] ?? '/';
        const androidDetails = AndroidNotificationDetails(
          'campus_channel', 
          'Pengumuman Kampus',
          importance: Importance.high, 
          priority: Priority.high,
        );
        
        await _local.show(
          id: message.hashCode,
          title: message.notification?.title ?? 'Pengumuman',
          body: message.notification?.body ?? '',
          notificationDetails: const NotificationDetails(android: androidDetails),
          payload: route,
        );
      });
    } catch (e) {
      debugPrint('FCM listenForeground error: $e');
    }
  }

  void setupNotificationClicks(void Function(String route) onNavigate) {
    try {
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final route = message.data['route'] ?? '/';
        onNavigate(route);
      });

      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          final route = message.data['route'] ?? '/';
          onNavigate(route);
        } else if (pendingDeepLink != null) {
          onNavigate(pendingDeepLink!);
          pendingDeepLink = null;
        }
      }).catchError((e) {
        debugPrint('FCM getInitialMessage error: $e');
      });
    } catch (e) {
      debugPrint('FCM setupNotificationClicks error: $e');
    }
  }
}
