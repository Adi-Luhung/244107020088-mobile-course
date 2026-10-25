import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/usecases/get_announcements.dart';
import '../../domain/usecases/search_announcements.dart';

// Injeksi Data Layer
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return const AnnouncementRepositoryImpl();
});

// Injeksi Domain Layer (Use Cases)
final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  return GetAnnouncements(repository);
});

final searchAnnouncementsProvider = Provider<SearchAnnouncements>((ref) {
  return const SearchAnnouncements();
});

// Notifier untuk mengelola teks pencarian pengguna
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

// Presentation Layer State (Fetch Raw Data)
final announcementsStateProvider = FutureProvider<List<Announcement>>((
  ref,
) async {
  final useCase = ref.watch(getAnnouncementsProvider);
  final result = await useCase.call();

  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.announcements;
});

// Presentation Layer State (Hasil Filtered Data berdasarkan Search Query)
final filteredAnnouncementsProvider = Provider<AsyncValue<List<Announcement>>>((
  ref,
) {
  final asyncAnnouncements = ref.watch(announcementsStateProvider);
  final query = ref.watch(searchQueryProvider);
  final searchUseCase = ref.watch(searchAnnouncementsProvider);

  return asyncAnnouncements.whenData((list) {
    return searchUseCase(announcements: list, query: query);
  });
});
