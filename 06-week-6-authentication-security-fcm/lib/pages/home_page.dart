import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _truncatedToken = 'Memuat token...';

  @override
  void initState() {
    super.initState();
    _loadFcmToken();
  }

  Future<void> _loadFcmToken() async {
    setState(() => _truncatedToken = 'Memuat token...');
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.length > 12) {
        setState(() => _truncatedToken = '${token.substring(0, 12)}...');
      } else if (token != null) {
        setState(() => _truncatedToken = token);
      } else {
        setState(() => _truncatedToken = 'Token tidak ditemukan');
      }
    } catch (e) {
      debugPrint('FCM getToken error: $e');
      setState(() => _truncatedToken = 'google-services.json belum dikonfigurasi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: Colors.blueAccent,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, Mahasiswa!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Aplikasi Anda siap menerima notifikasi akademik.', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Panel Informasi Debug (Bukti Laporan)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FCM Token (12 Karakter Pertama):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  SelectableText(_truncatedToken, style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
