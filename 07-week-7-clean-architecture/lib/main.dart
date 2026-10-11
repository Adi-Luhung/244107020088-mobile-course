import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/announcements/presentation/pages/announcements_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CampusNotifyCleanApp(),
    ),
  );
}

class CampusNotifyCleanApp extends ConsumerWidget {
  const CampusNotifyCleanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authStateProvider).value ?? false;

    return MaterialApp(
      title: 'Campus Notify - Clean Architecture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // Simulasi Guard Route Sederhana memanfaatkan state login dari Clean Auth Layer
      home: isLoggedIn ? const AnnouncementsPage() : const Scaffold(
        body: Center(
          child: Text('Halaman Login (Akses Terproteksi Clean Architecture)'),
        ),
      ),
    );
  }
}
