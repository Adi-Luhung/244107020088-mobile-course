import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/usecases/search_announcements.dart';

void main() {
  group('SearchAnnouncements Domain Use Case Test', () {
    const searchUseCase = SearchAnnouncements();

    final dummyList = [
      Announcement(
        id: '1',
        title: 'Jadwal Ujian Tengah Semester Ganjil',
        body:
            'Pelaksanaan UTS akan diselenggarakan secara luring di Gedung TI.',
        createdAt: DateTime(2026, 10, 1),
      ),
      Announcement(
        id: '2',
        title: 'Pendaftaran Beasiswa Unggulan',
        body:
            'Batas akhir pengumpulan berkas administrasi beasiswa tanggal 30.',
        createdAt: DateTime(2026, 10, 5),
      ),
      Announcement(
        id: '3',
        title: 'Workshop Flutter & AI Coding',
        body: 'Belajar arsitektur Flutter bersama praktisi industri.',
        createdAt: DateTime(2026, 10, 10),
      ),
    ];

    test('Query kosong atau spasi saja harus mengembalikan semua daftar pengumuman', () {
      final resultEmpty = searchUseCase(announcements: dummyList, query: '');
      expect(resultEmpty.length, 3);

      final resultWhitespace = searchUseCase(
        announcements: dummyList,
        query: '   ',
      );
      expect(resultWhitespace.length, 3);
    });

    test(
      'Pencarian harus case-insensitive (mengabaikan huruf besar/kecil)',
      () {
        final resultLower = searchUseCase(
          announcements: dummyList,
          query: 'uts',
        );
        expect(resultLower.length, 1);
        expect(resultLower.first.id, '1');

        final resultUpper = searchUseCase(
          announcements: dummyList,
          query: 'BEASISWA',
        );
        expect(resultUpper.length, 1);
        expect(resultUpper.first.id, '2');

        final resultMixed = searchUseCase(
          announcements: dummyList,
          query: 'fLuTtEr',
        );
        expect(resultMixed.length, 1);
        expect(resultMixed.first.id, '3');
      },
    );

    test('Pencarian yang tidak cocok dengan judul maupun isi harus mengembalikan list kosong', () {
      final result = searchUseCase(
        announcements: dummyList,
        query: 'zzz-tidak-ada',
      );
      expect(result, isEmpty);
    });

    test(
      'Pencarian harus dapat mencocokkan kata yang ada di dalam body/deskripsi',
      () {
        final result = searchUseCase(
          announcements: dummyList,
          query: 'Gedung TI',
        );
        expect(result.length, 1);
        expect(result.first.id, '1');
      },
    );
  });
}
