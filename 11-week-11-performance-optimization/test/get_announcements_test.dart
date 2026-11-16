import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcements.dart';

class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository({this.shouldFail = false, this.isEmpty = false});
  final bool shouldFail;
  final bool isEmpty;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAnnouncements() async {
    if (shouldFail) {
      return (
        announcements: <Announcement>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }

    if (isEmpty) {
      return (announcements: <Announcement>[], failure: null);
    }

    return (
      announcements: [
        Announcement(
          id: '1',
          title: 'Uji Coba A',
          body: 'Konten Uji Coba',
          createdAt: DateTime(2026, 9, 27),
        ),
      ],
      failure: null,
    );
  }
}

void main() {
  group('Pengujian Clean Architecture Use Case - Week 7', () {
    test(
      'GetAnnouncements harus meneruskan data sukses dari repositori palsu',
      () async {
        final repo = FakeAnnouncementRepository(shouldFail: false);
        final useCase = GetAnnouncements(repo);

        final result = await useCase.call();

        expect(result.failure, isNull);
        expect(result.announcements.length, 1);
        expect(result.announcements.first.title, 'Uji Coba A');
      },
    );

    test(
      'GetAnnouncements harus meneruskan failure tanpa melempar error crash',
      () async {
        final repo = FakeAnnouncementRepository(shouldFail: true);
        final useCase = GetAnnouncements(repo);

        final result = await useCase.call();

        expect(result.announcements, isEmpty);
        expect(result.failure, isA<LocalFailure>());
        expect(result.failure?.message, 'db locked (simulasi)');
      },
    );

    test(
      'GetAnnouncements harus menangani skenario list kosong dengan benar',
      () async {
        final repo = FakeAnnouncementRepository(isEmpty: true);
        final useCase = GetAnnouncements(repo);

        final result = await useCase.call();

        expect(result.failure, isNull);
        expect(result.announcements, isEmpty);
      },
    );
  });
}
