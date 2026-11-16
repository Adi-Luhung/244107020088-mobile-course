import '../../../../core/failures.dart';
import '../entities/ai_summary.dart';
import '../repositories/ai_repository.dart';

class SummarizeAnnouncement {
  final AiRepository _repository;

  const SummarizeAnnouncement(this._repository);

  Future<({AiSummary? summary, Failure? failure})> call({
    required String announcementId,
    required String title,
    required String body,
  }) async {
    if (announcementId.trim().isEmpty) {
      return (
        summary: null,
        failure: const AiServiceFailure('ID pengumuman tidak valid.'),
      );
    }

    if (body.trim().isEmpty && title.trim().isEmpty) {
      return (
        summary: null,
        failure: const AiServiceFailure('Konten pengumuman kosong.'),
      );
    }

    return _repository.summarizeAnnouncement(
      announcementId: announcementId.trim(),
      title: title.trim(),
      body: body.trim(),
    );
  }
}
