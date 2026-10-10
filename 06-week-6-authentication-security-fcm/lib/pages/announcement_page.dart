import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pengumuman ID: #$id', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            const Text('Perubahan Jadwal Kuliah Mobile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Kelas Pemrograman Mobile dialihkan ke Ruang Laboratorium A2 jam 13.00 WIB.', style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
