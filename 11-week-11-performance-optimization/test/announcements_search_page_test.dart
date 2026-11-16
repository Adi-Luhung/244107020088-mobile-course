import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/presentation/pages/announcements_page.dart';
import 'package:campus_notify/features/announcements/presentation/providers/announcements_providers.dart';

void main() {
  final testAnnouncements = [
    Announcement(
      id: '1',
      title: 'Pengumuman KRS Semester Ganjil',
      body: 'Pengisian KRS dibuka mulai tanggal 1 sampai 10 September.',
      createdAt: DateTime(2026, 9, 1),
    ),
    Announcement(
      id: '2',
      title: 'Beasiswa Prestasi Akademik',
      body: 'Pendaftaran beasiswa untuk mahasiswa berprestasi.',
      createdAt: DateTime(2026, 9, 5),
    ),
  ];

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        announcementsStateProvider.overrideWith(
          (ref) => Future.value(testAnnouncements),
        ),
      ],
      child: const MaterialApp(home: AnnouncementsPage()),
    );
  }

  testWidgets(
    'Menampilkan daftar pengumuman awal dan menyaring hasil saat mengetik di search bar',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Memastikan kedua judul tampil saat awal
      expect(find.text('Pengumuman KRS Semester Ganjil'), findsOneWidget);
      expect(find.text('Beasiswa Prestasi Akademik'), findsOneWidget);

      // Ketik kata kunci 'KRS'
      final searchField = find.byKey(const Key('search_text_field'));
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'krs');
      await tester.pumpAndSettle();

      // Hasil filter: hanya item KRS yang tampil
      expect(find.text('Pengumuman KRS Semester Ganjil'), findsOneWidget);
      expect(find.text('Beasiswa Prestasi Akademik'), findsNothing);
    },
  );

  testWidgets(
    'Menampilkan Empty State yang informatif saat hasil pencarian tidak cocok',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Masukkan query pencarian yang tidak ada di daftar
      final searchField = find.byKey(const Key('search_text_field'));
      await tester.enterText(searchField, 'wisuda-tidak-ada');
      await tester.pumpAndSettle();

      // Memverifikasi teks empty state spesifik muncul
      expect(find.byKey(const Key('empty_state_container')), findsOneWidget);
      expect(
        find.text('Tidak ditemukan pengumuman untuk "wisuda-tidak-ada"'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    },
  );

  testWidgets(
    'Tombol clear pada search bar harus mengosongkan query dan mengembalikan seluruh daftar',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final searchField = find.byKey(const Key('search_text_field'));
      await tester.enterText(searchField, 'beasiswa');
      await tester.pumpAndSettle();

      expect(find.text('Beasiswa Prestasi Akademik'), findsOneWidget);
      expect(find.text('Pengumuman KRS Semester Ganjil'), findsNothing);

      // Tekan tombol clear (ikon silang)
      final clearButton = find.byKey(const Key('clear_search_button'));
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Semua daftar kembali muncul
      expect(find.text('Pengumuman KRS Semester Ganjil'), findsOneWidget);
      expect(find.text('Beasiswa Prestasi Akademik'), findsOneWidget);
    },
  );
}
