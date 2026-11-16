import '../../../../core/cache/cache_manager.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final CacheManager<String, List<Announcement>> _cacheManager;

  AnnouncementRepositoryImpl({
    CacheManager<String, List<Announcement>>? cacheManager,
  }) : _cacheManager = cacheManager ??
            CacheManager<String, List<Announcement>>(
              defaultTtl: const Duration(minutes: 5),
            );

  CacheManager<String, List<Announcement>> get cacheManager => _cacheManager;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAnnouncements({bool forceRefresh = false}) async {
    const cacheKey = 'all_announcements';

    // 1. Caching Layer Check (Fast Path - 0ms latency)
    if (!forceRefresh) {
      final cached = _cacheManager.get(cacheKey);
      if (cached != null) {
        return (announcements: cached, failure: null);
      }
    } else {
      _cacheManager.invalidate(cacheKey);
    }

    // 2. Slow Path (Fetch from DB/Network)
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final List<Map<String, Object?>> mockData = [
        {
          'id': '1',
          'title': 'Jadwal Ujian Tengah Semester Ganjil',
          'body': 'Pelaksanaan UTS akan diselenggarakan secara luring di Gedung TI.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'title': 'Pendaftaran Beasiswa Unggulan',
          'body': 'Batas akhir pengumpulan berkas administrasi beasiswa tanggal 30.',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '3',
          'title': 'Perubahan Jadwal Kuliah Mobile',
          'body': 'Kelas Pemrograman Mobile hari ini dialihkan ke Lab A2 jam 13.00 WIB.',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      final announcements = mockData
          .map((e) => AnnouncementModel.fromMap(e))
          .toList();

      // Simpan ke Cache
      _cacheManager.set(cacheKey, announcements);

      return (announcements: announcements, failure: null);
    } catch (e) {
      return (
        announcements: <Announcement>[],
        failure: const LocalFailure('Gagal memuat data pengumuman'),
      );
    }
  }
}
