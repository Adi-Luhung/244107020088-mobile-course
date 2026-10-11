import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/announcements_providers.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman Akademik')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Terjadi Kesalahan: ${error.toString().replaceAll('Exception: ', '')}'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(announcementsStateProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (announcements) {
          if (announcements.isEmpty) {
            return const Center(child: Text('Belum ada catatan pengumuman.'));
          }
          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final item = announcements[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: const Icon(Icons.campaign, color: Colors.blueAccent),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(item.body),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
