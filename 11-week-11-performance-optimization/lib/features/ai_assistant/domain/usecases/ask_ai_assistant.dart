import '../../../../core/failures.dart';
import '../entities/chat_message.dart';
import '../repositories/ai_repository.dart';

class AskAiAssistant {
  final AiRepository _repository;

  const AskAiAssistant(this._repository);

  Future<({ChatMessage? response, Failure? failure})> call({
    required String prompt,
    required List<ChatMessage> history,
    List<String>? contextAnnouncements,
    bool isVoiceInput = false,
  }) async {
    final sanitizedPrompt = prompt.trim();
    if (sanitizedPrompt.isEmpty) {
      return (
        response: null,
        failure: const AiServiceFailure('Pertanyaan tidak boleh kosong.'),
      );
    }

    return _repository.askAssistant(
      prompt: sanitizedPrompt,
      history: history,
      contextAnnouncements: contextAnnouncements,
      isVoiceInput: isVoiceInput,
    );
  }
}
