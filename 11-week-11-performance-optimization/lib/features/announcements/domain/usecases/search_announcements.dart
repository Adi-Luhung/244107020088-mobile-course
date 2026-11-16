import 'dart:isolate';
import '../entities/announcement.dart';

/// Parameter helper untuk isolasi thread
class SearchFilterParam {
  final List<Announcement> announcements;
  final String query;

  const SearchFilterParam({required this.announcements, required this.query});
}

/// Pure Domain Use Case untuk memfilter / mencari pengumuman.
/// Mendukung eksekusi sinkron dan pemrosesan asinkron di Background Isolate (Non-blocking UI).
class SearchAnnouncements {
  const SearchAnnouncements();

  /// Eksekusi logika pencarian filter
  static List<Announcement> _performSearch(SearchFilterParam param) {
    final trimmedQuery = param.query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      return param.announcements;
    }

    return param.announcements.where((announcement) {
      final titleMatch =
          announcement.title.toLowerCase().contains(trimmedQuery);
      final bodyMatch = announcement.body.toLowerCase().contains(trimmedQuery);
      return titleMatch || bodyMatch;
    }).toList();
  }

  /// Pemanggilan sinkron standar (kompatibel penuh dengan kode lama & pengujian)
  List<Announcement> call({
    required List<Announcement> announcements,
    required String query,
  }) {
    return _performSearch(
      SearchFilterParam(announcements: announcements, query: query),
    );
  }

  /// Pemrosesan komputasi berat di Background Isolate (Optimasi Performa 60/120 FPS)
  Future<List<Announcement>> executeInIsolate({
    required List<Announcement> announcements,
    required String query,
  }) async {
    final param = SearchFilterParam(announcements: announcements, query: query);
    // Jalankan di thread Isolate terpisah agar tidak membebani main UI thread
    return Isolate.run(() => _performSearch(param));
  }
}
