import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ai_remote_data_source.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/usecases/ask_ai_assistant.dart';
import '../../domain/usecases/summarize_announcement.dart';

// 1. Data Source & Repository Provider
final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) {
  return AiRemoteDataSourceImpl();
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final dataSource = ref.watch(aiRemoteDataSourceProvider);
  return AiRepositoryImpl(dataSource);
});

// 2. Use Case Providers
final summarizeAnnouncementUseCaseProvider = Provider<SummarizeAnnouncement>((
  ref,
) {
  final repository = ref.watch(aiRepositoryProvider);
  return SummarizeAnnouncement(repository);
});

final askAiAssistantUseCaseProvider = Provider<AskAiAssistant>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return AskAiAssistant(repository);
});

// 3. Voice Recording State Notifier (Simulasi Speech-to-Text Input)
class VoiceRecordingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void stop() => state = false;
  void start() => state = true;
}

final voiceRecordingProvider = NotifierProvider<VoiceRecordingNotifier, bool>(
  VoiceRecordingNotifier.new,
);

// 4. Chat Assistant State Notifier
class AiChatNotifier extends Notifier<AsyncValue<List<ChatMessage>>> {
  @override
  AsyncValue<List<ChatMessage>> build() {
    return AsyncData([
      ChatMessage(
        id: 'welcome',
        text: 'Halo Adi Luhung! Saya Asisten AI Akademik JTI Polinema. Ada yang bisa saya bantu terkait jadwal perkuliahan, pengumuman UTS, atau panduan beasiswa?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ]);
  }

  Future<void> sendMessage(String text, {bool isVoice = false}) async {
    final currentList = state.value ?? [];
    final userMessage = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      isVoiceInput: isVoice,
    );

    // Optimistic Update: Tambahkan pesan user & pasang state loading respons AI
    final updatedList = [...currentList, userMessage];
    state = AsyncData(updatedList);

    final useCase = ref.read(askAiAssistantUseCaseProvider);
    final result = await useCase(
      prompt: text,
      history: updatedList,
      isVoiceInput: isVoice,
    );

    if (result.failure != null) {
      final errorMsg = ChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Maaf, terjadi kendala AI: ${result.failure!.message}',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = AsyncData([...updatedList, errorMsg]);
    } else if (result.response != null) {
      state = AsyncData([...updatedList, result.response!]);
    }
  }

  void clearHistory() {
    state = AsyncData([
      ChatMessage(
        id: 'welcome_reset',
        text: 'Percakapan telah dibersihkan. Silakan ajukan pertanyaan baru mengenai informasi akademik kampus!',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ]);
  }
}

final aiChatProvider =
    NotifierProvider<AiChatNotifier, AsyncValue<List<ChatMessage>>>(
      AiChatNotifier.new,
    );
