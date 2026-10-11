import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';
import '../../../../core/failures.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  const AnnouncementRepositoryImpl();

  @override
  Future<({List<Announcement> announcements, Failure? failure})> fetchAnnouncements() async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      // Simulasi payload data dari backend/database lokal
      final List<Map<String, Object?>> mockData = [
        {
          'id': '3',
          'title': 'Perubahan Jadwal Kuliah Mobile',
          'body': 'Kelas Pemrograman Mobile hari ini dialihkan ke Lab A2 jam 13.00 WIB.',
          'created_at': DateTime.now().toIso8601String(),
        }
      ];

      final announcements = mockData.map((e) => AnnouncementModel.fromMap(e)).toList();
      return (announcements: announcements, failure: null);
        } catch (e) {
      // PERBAIKAN: Pastikan objek LocalFailure dikirim dengan benar, bukan const kosong
      return (announcements: <Announcement>[], failure: const LocalFailure('Gagal memuat data pengumuman'));
    }
  }
}
