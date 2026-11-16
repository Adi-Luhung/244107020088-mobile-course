import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/ai_assistant/domain/entities/ai_summary.dart';
import 'package:campus_notify/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:campus_notify/features/ai_assistant/domain/repositories/ai_repository.dart';
import 'package:campus_notify/features/ai_assistant/domain/usecases/summarize_announcement.dart';

class FakeAiRepository implements AiRepository {
  final bool shouldFail;

  FakeAiRepository({this.shouldFail = false});

  @override
  Future<({AiSummary? summary, Failure? failure})> summarizeAnnouncement({
    required String announcementId,
    required String title,
    required String body,
  }) async {
    if (shouldFail) {
      return (
        summary: null,
        failure: const AiServiceFailure(
          'Koneksi layanan AI timeout (simulasi)',
        ),
      );
    }

    return (
      summary: AiSummary(
        announcementId: announcementId,
        summary: 'Ringkasan: $title. Poin penting telah disaring.',
        actionItems: ['Cek portal SIAKAD', 'Hadir tepat waktu'],
        urgencyLevel: 'Tinggi',
        generatedAt: DateTime(2026, 11, 15),
      ),
      failure: null,
    );
  }

  @override
  Future<({ChatMessage? response, Failure? failure})> askAssistant({
    required String prompt,
    required List<ChatMessage> history,
    List<String>? contextAnnouncements,
    bool isVoiceInput = false,
  }) async {
    return (
      response: ChatMessage(
        id: 'reply_1',
        text: 'Jawaban AI untuk: $prompt',
        isUser: false,
        timestamp: DateTime(2026, 11, 15),
        isVoiceInput: isVoiceInput,
      ),
      failure: null,
    );
  }
}

void main() {
  group('SummarizeAnnouncement Use Case Test', () {
    test(
      'Harus mengembalikan ringkasan AI sukses jika parameter valid',
      () async {
        final repo = FakeAiRepository(shouldFail: false);
        final useCase = SummarizeAnnouncement(repo);

        final result = await useCase(
          announcementId: '101',
          title: 'Jadwal UTS Semester Ganjil',
          body: 'Ujian akan berlangsung luring di Gedung TI.',
        );

        expect(result.failure, isNull);
        expect(result.summary, isNotNull);
        expect(result.summary!.announcementId, '101');
        expect(result.summary!.actionItems.length, 2);
        expect(result.summary!.urgencyLevel, 'Tinggi');
      },
    );

    test(
      'Harus meneruskan failure saat layanan repositori AI mengalami error',
      () async {
        final repo = FakeAiRepository(shouldFail: true);
        final useCase = SummarizeAnnouncement(repo);

        final result = await useCase(
          announcementId: '101',
          title: 'Pengumuman Apapun',
          body: 'Isi pengumuman',
        );

        expect(result.summary, isNull);
        expect(result.failure, isA<AiServiceFailure>());
        expect(
          result.failure!.message,
          'Koneksi layanan AI timeout (simulasi)',
        );
      },
    );

    test(
      'Harus memvalidasi guard clause ketika ID pengumuman kosong',
      () async {
        final repo = FakeAiRepository();
        final useCase = SummarizeAnnouncement(repo);

        final result = await useCase(
          announcementId: '   ',
          title: 'Judul Valid',
          body: 'Body Valid',
        );

        expect(result.summary, isNull);
        expect(result.failure, isNotNull);
        expect(result.failure!.message, 'ID pengumuman tidak valid.');
      },
    );

    test(
      'Harus memvalidasi guard clause ketika konten judul dan body kosong',
      () async {
        final repo = FakeAiRepository();
        final useCase = SummarizeAnnouncement(repo);

        final result = await useCase(
          announcementId: '102',
          title: '',
          body: '   ',
        );

        expect(result.summary, isNull);
        expect(result.failure, isNotNull);
        expect(result.failure!.message, 'Konten pengumuman kosong.');
      },
    );
  });
}
