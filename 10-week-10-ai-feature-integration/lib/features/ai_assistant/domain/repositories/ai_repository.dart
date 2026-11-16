import '../../../../core/failures.dart';
import '../entities/ai_summary.dart';
import '../entities/chat_message.dart';

abstract class AiRepository {
  Future<({AiSummary? summary, Failure? failure})> summarizeAnnouncement({
    required String announcementId,
    required String title,
    required String body,
  });

  Future<({ChatMessage? response, Failure? failure})> askAssistant({
    required String prompt,
    required List<ChatMessage> history,
    List<String>? contextAnnouncements,
    bool isVoiceInput = false,
  });
}
