import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week5_offline_notes/data/local/note.dart';

void main() {
  // Mengaktifkan binding pengujian sejak awal
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Menyediakan nilai awal kosong untuk mock SharedPreferences bawaan library
    SharedPreferences.setMockInitialValues({});
  });

  test('fromMap aman terhadap field yang hilang (Edge Case)', () {
    final note = Note.fromMap({'title': 'Belanja Kulakan'});
    expect(note.title, 'Belanja Kulakan');
    expect(note.body, '');
    expect(note.dirty, isFalse);
  });

  test('flag dirty bertahan pada proses serialisasi data toMap', () {
    final note = Note(
      title: 'Tugas Mobile Week 5',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );
    final restored = Note.fromMap(note.toMap());
    expect(restored.dirty, isTrue);
    expect(restored.title, 'Tugas Mobile Week 5');
  });

  test('Konversi toMap menghasilkan tipe data data yang valid untuk SQLite', () {
    final note = Note(
      title: 'Catatan Kuliah',
      body: 'Materi Offline-First',
      updatedAt: DateTime(2026, 10, 2),
      dirty: true,
    );
    final map = note.toMap();
    expect(map['title'], 'Catatan Kuliah');
    expect(map['body'], 'Materi Offline-First');
    expect(map['dirty'], 1); // 1 mewakili true pada database SQLite
  });
}
