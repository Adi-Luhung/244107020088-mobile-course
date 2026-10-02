import 'repositories/note_repository.dart';

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;

  // Simulasi proses upload payload data ke server REST API asli
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced(); // Tandai sukses tersinkronisasi jika server merespons
  return dirtyCount;
}
