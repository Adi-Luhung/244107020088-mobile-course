import 'package:dio/dio.dart';

import '../models/ai_summary_model.dart';
import '../models/chat_message_model.dart';

abstract class AiRemoteDataSource {
  Future<AiSummaryModel> generateSummary({
    required String announcementId,
    required String title,
    required String body,
  });

  Future<ChatMessageModel> generateAssistantReply({
    required String prompt,
    List<String>? contextAnnouncements,
    bool isVoiceInput = false,
  });
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final Dio? dio;
  final String? apiKey;

  AiRemoteDataSourceImpl({this.dio, this.apiKey});

  @override
  Future<AiSummaryModel> generateSummary({
    required String announcementId,
    required String title,
    required String body,
  }) async {
    // Simulasi delay pemrosesan inferensi AI
    await Future.delayed(const Duration(milliseconds: 350));

    // Analisis heuristik AI pada konten pengumuman
    final lowerTitle = title.toLowerCase();
    final lowerBody = body.toLowerCase();
    final combined = '$lowerTitle $lowerBody';

    String urgency = 'Informasi';
    if (combined.contains('penting') ||
        combined.contains('wajib') ||
        combined.contains('batas') ||
        combined.contains('uts') ||
        combined.contains('uas')) {
      urgency = 'Tinggi';
    } else if (combined.contains('beasiswa') ||
        combined.contains('workshop') ||
        combined.contains('jadwal')) {
      urgency = 'Sedang';
    }

    // Ekstraksi poin aksi (Action Items) cerdas
    final actionItems = <String>[];
    if (combined.contains('uts') || combined.contains('ujian')) {
      actionItems.add(
        'Cetak Kartu Ujian dan periksa jadwal ruang di Gedung TI.',
      );
      actionItems.add('Hadir tepat waktu 15 menit sebelum sesi dimulai.');
    } else if (combined.contains('beasiswa')) {
      actionItems.add('Siapkan transkrip nilai akademik terbaru.');
      actionItems.add('Kumpulkan berkas administrasi sebelum batas waktu.');
    } else if (combined.contains('workshop') || combined.contains('kuliah')) {
      actionItems.add('Lakukan registrasi presensi kehadiran.');
      actionItems.add('Bawa laptop dengan SDK Flutter yang telah terinstal.');
    } else {
      actionItems.add(
        'Catat informasi penting ini ke dalam kalender akademik.',
      );
      actionItems.add('Hubungi bagian akademik jika membutuhkan klarifikasi.');
    }

    final summaryText =
        'Intisari: $title. Dokumen ini menekankan hal krusial: $body. '
        'Mahasiswa diharapkan memperhatikan detail instruksi dan memenuhi persyaratan yang telah ditentukan.';

    return AiSummaryModel(
      announcementId: announcementId,
      summary: summaryText,
      actionItems: actionItems,
      urgencyLevel: urgency,
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<ChatMessageModel> generateAssistantReply({
    required String prompt,
    List<String>? contextAnnouncements,
    bool isVoiceInput = false,
  }) async {
    // Simulasi respons latensi model cerdas
    await Future.delayed(const Duration(milliseconds: 400));

    final cleanPrompt = prompt.toLowerCase().trim();
    String replyText = '';

    if (cleanPrompt.contains('uts') || cleanPrompt.contains('ujian')) {
      replyText =
          'Halo! Mengenai Pelaksanaan UTS Ganjil, ujian diselenggarakan secara luring di Gedung TI JTI Polinema. '
          'Pastikan Anda membawa KTM dan Kartu Ujian fisik ya!';
    } else if (cleanPrompt.contains('beasiswa')) {
      replyText =
          'Untuk Pendaftaran Beasiswa Unggulan, batas akhir pengumpulan berkas adalah tanggal 30 bulan ini. '
          'Syarat utama: IPK minimal 3.25 dan surat rekomendasi Dosen Pembimbing.';
    } else if (cleanPrompt.contains('workshop') ||
        cleanPrompt.contains('flutter')) {
      replyText =
          'Workshop Flutter & AI Coding akan membahas best practice arsitektur Clean Architecture dan integrasi AI Assistant. '
          'Silakan siapkan laptop dan VS Code/Android Studio yang sudah terkonfigurasi Flutter SDK 3.x.';
    } else if (cleanPrompt.contains('krs') || cleanPrompt.contains('jadwal')) {
      replyText =
          'Jadwal pengisian dan revisi KRS dapat diakses melalui portal SIAKAD kampus. '
          'Konsultasikan rencana studi Anda dengan Dosen Pembina Akademik (DPA).';
    } else if (cleanPrompt.contains('halo') || cleanPrompt.contains('hai')) {
      replyText = 'Halo! Saya Asisten AI Akademik JTI Polinema. Saya dapat membantu Anda merangkum pengumuman, menjelaskan syarat beasiswa, jadwal ujian, atau panduan perkuliahan.';
    } else {
      replyText =
          'Terima kasih atas pertanyaan Anda: "$prompt". '
          'Berdasarkan arsip pengumuman akademik terbaru di kampus, silakan periksa papan pengumuman utama atau diskusikan dengan bagian akademik JTI Polinema.';
    }

    return ChatMessageModel(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      isVoiceInput: isVoiceInput,
    );
  }
}
