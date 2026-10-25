import '../entities/announcement.dart';

/// Pure Domain Use Case untuk memfilter / mencari pengumuman berdasarkan kata kunci judul atau isi.
/// Didesain independen dari Flutter/Dio/SQLite sesuai aturan Clean Architecture.
class SearchAnnouncements {
  const SearchAnnouncements();

  List<Announcement> call({
    required List<Announcement> announcements,
    required String query,
  }) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      return announcements;
    }

    return announcements.where((announcement) {
      final titleMatch = announcement.title.toLowerCase().contains(
        trimmedQuery,
      );
      final bodyMatch = announcement.body.toLowerCase().contains(trimmedQuery);
      return titleMatch || bodyMatch;
    }).toList();
  }
}
