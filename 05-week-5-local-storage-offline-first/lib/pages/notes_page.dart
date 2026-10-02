import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notes_provider.dart';
import 'note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final darkModeAsync = ref.watch(darkModeProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline-First Notes'),
        actions: [
          // Badge Antrean Sinkronisasi (Pola Outbox)
          dirtyCountAsync.when(
            data: (count) => count > 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      key: const Key('sync_badge'),
                      child: Badge(label: Text('$count'), child: const Icon(Icons.sync_problem)),
                    ),
                  )
                : const Icon(Icons.cloud_done, color: Colors.green),
            error: (_, _) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => ref.read(notesProvider.notifier).sync(),
          ),
          IconButton(
            icon: Icon(darkModeAsync.value ?? false ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => ref.read(darkModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat: $err')),
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('Belum ada catatan lokal.'))
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteTile(
                    note: note,
                    onTap: () => context.go('/note/${note.id}'), // Navigasi Parameter
                    onDelete: () => ref.read(notesProvider.notifier).delete(note.id!),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Judul')),
            TextField(controller: bodyController, decoration: const InputDecoration(labelText: 'Isi')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                ref.read(notesProvider.notifier).add(
                      titleController.text.trim(),
                      bodyController.text.trim(),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
