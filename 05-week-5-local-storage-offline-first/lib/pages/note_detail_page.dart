import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';

class NoteDetailPage extends ConsumerWidget {
  final int noteId;
  const NoteDetailPage({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (notes) {
          final note = notes.firstWhere((n) => n.id == noteId,
              orElse: () => throw Exception('Catatan tidak ditemukan'));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            key: const Key('detail_content'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Diperbarui: ${note.updatedAt.toLocal()}',
                    style: const TextStyle(color: Colors.grey)),
                const Divider(height: 24),
                Expanded(child: SingleChildScrollView(child: Text(note.body))),
              ],
            ),
          );
        },
      ),
    );
  }
}
