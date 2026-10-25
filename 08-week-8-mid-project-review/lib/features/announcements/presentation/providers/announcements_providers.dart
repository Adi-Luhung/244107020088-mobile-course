import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/usecases/get_announcements.dart';

// Injeksi Data Layer
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return const AnnouncementRepositoryImpl();
});

// Injeksi Domain Layer (Use Case)
final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  return GetAnnouncements(repository);
});

// Presentation Layer State
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
