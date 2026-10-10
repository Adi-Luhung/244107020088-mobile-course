import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'providers/auth_provider.dart';
import 'messaging/push_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';

final pushServiceProvider = Provider<PushService>((ref) {
  return PushService(); 
});

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authStateProvider).value ?? false;

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final goingToLogin = state.matchedLocation == '/login';
      if (!isLoggedIn && !goingToLogin) return '/login'; 
      if (isLoggedIn && goingToLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login', 
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/', 
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) => AnnouncementPage(id: state.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(); 
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  runApp(const ProviderScope(child: CampusNotifyApp()));
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNotificationLifecycle();
    });
  }

  Future<void> _setupNotificationLifecycle() async {
    final pushService = ref.read(pushServiceProvider);
    final router = ref.read(routerProvider);

    final isGranted = await pushService.requestNotificationPermission();
    if (isGranted) {
      await pushService.initLocalNotifications();
      await pushService.initFcmToken(onToken: (token) async {
        final shortToken = token.length > 12 ? token.substring(0, 12) : token;
        debugPrint('FCM Token Terdaftar: $shortToken...');
      });

      pushService.listenForeground();
      pushService.setupNotificationClicks((route) {
        router.push(route);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
