import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/prefs.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';

// Providers Global
final prefsRepositoryProvider = Provider((ref) => PrefsRepository());
final noteRepositoryProvider = Provider((ref) => NoteRepository());

// 1. Dark Mode State Management
class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final current = state.value ?? false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(!current);
      return !current;
    });
  }
}
final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

// 2. Note List & Sync State Management
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    await ref.read(prefsRepositoryProvider).markOpenedNow();
    return ref.watch(noteRepositoryProvider).fetchNotes();
  }

  Future<void> add(String title, String body) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(noteRepositoryProvider);
      await repo.addNote(title: title, body: body);
      return repo.fetchNotes();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(noteRepositoryProvider);
      await repo.deleteNote(id);
      return repo.fetchNotes();
    });
  }

  Future<void> sync() async {
    final repo = ref.read(noteRepositoryProvider);
    await syncNotes(repo);
    ref.invalidateSelf(); // Segarkan UI lokal setelah sinkronisasi berhasil
  }
}
final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

// 3. Count Outbox Badge Pending Provider
final dirtyCountProvider = FutureProvider<int>((ref) {
  ref.watch(notesProvider); // Bangun ulang badge tiap kali data list berubah
  return ref.read(noteRepositoryProvider).countDirty();
});
