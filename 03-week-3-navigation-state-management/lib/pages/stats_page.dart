import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/todo_provider.dart';

class StatsNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final total = ref.watch(todoListProvider).length;
    final active = ref.watch(activeTodosProvider).length;
    
    return "Total Tugas: $total\nTugas Aktif Belum Selesai: $active";
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, String>(StatsNotifier.new);

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Academic ToDo Stats')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gagal memuat statistik: $err', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(statsProvider), 
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
          data: (dataString) => Center(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  dataString,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
