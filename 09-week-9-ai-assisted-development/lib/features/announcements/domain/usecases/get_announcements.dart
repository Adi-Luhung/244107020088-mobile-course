import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';
import '../../../../core/failures.dart';

class GetAnnouncements {
  const GetAnnouncements(this._repository);
  final AnnouncementRepository _repository;

  Future<({List<Announcement> announcements, Failure? failure})> call() {
    return _repository.fetchAnnouncements();
  }
}
