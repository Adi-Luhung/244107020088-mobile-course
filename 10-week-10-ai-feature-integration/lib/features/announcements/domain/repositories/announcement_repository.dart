import '../entities/announcement.dart';
import '../../../../core/failures.dart';

abstract class AnnouncementRepository {
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAnnouncements();
}
