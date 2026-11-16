import '../../../../core/failures.dart';
import '../../domain/entities/ai_summary.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_data_source.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource _remoteDataSource;

  AiRepositoryImpl(this._remoteDataSource);

  @override
  Future<({AiSummary? summary, Failure? failure})> summarizeAnnouncement({
    required String announcementId,
    required String title,
    required String body,
  }) async {
    try {
      final model = await _remoteDataSource.generateSummary(
        announcementId: announcementId,
        title: title,
        body: body,
      );
      return (summary: model, failure: null);
    } catch (e) {
      return (
        summary: null,
        failure: AiServiceFailure(
          'Gagal menghasilkan ringkasan AI: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<({ChatMessage? response, Failure? failure})> askAssistant({
    required String prompt,
    required List<ChatMessage> history,
    List<String>? contextAnnouncements,
    bool isVoiceInput = false,
  }) async {
    try {
      final model = await _remoteDataSource.generateAssistantReply(
        prompt: prompt,
        contextAnnouncements: contextAnnouncements,
        isVoiceInput: isVoiceInput,
      );
      return (response: model, failure: null);
    } catch (e) {
      return (
        response: null,
        failure: AiServiceFailure('Gagal memproses pesan AI: ${e.toString()}'),
      );
    }
  }
}
