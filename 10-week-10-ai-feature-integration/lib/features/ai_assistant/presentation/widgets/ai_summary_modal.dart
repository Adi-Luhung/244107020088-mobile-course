import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ai_summary.dart';
import '../providers/ai_assistant_providers.dart';

class AiSummaryModal extends ConsumerStatefulWidget {
  final String announcementId;
  final String title;
  final String body;

  const AiSummaryModal({
    super.key,
    required this.announcementId,
    required this.title,
    required this.body,
  });

  static Future<void> show(
    BuildContext context, {
    required String announcementId,
    required String title,
    required String body,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiSummaryModal(
        announcementId: announcementId,
        title: title,
        body: body,
      ),
    );
  }

  @override
  ConsumerState<AiSummaryModal> createState() => _AiSummaryModalState();
}

class _AiSummaryModalState extends ConsumerState<AiSummaryModal> {
  bool _isLoading = true;
  AiSummary? _summary;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = ref.read(summarizeAnnouncementUseCaseProvider);
    final result = await useCase(
      announcementId: widget.announcementId,
      title: widget.title,
      body: widget.body,
    );

    if (!mounted) return;

    if (result.failure != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.failure!.message;
      });
    } else {
      setState(() {
        _isLoading = false;
        _summary = result.summary;
      });
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'tinggi':
        return Colors.redAccent;
      case 'sedang':
        return Colors.orangeAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.indigo,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan AI Pintar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ekstraksi Intisari & Poin Aksi Mahasiswa',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Menganalisis dokumen pengumuman...',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchSummary,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Urgensi Badge
                        Row(
                          children: [
                            const Text(
                              'Tingkat Urgensi:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getUrgencyColor(_summary!.urgencyLevel)
                                    .withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getUrgencyColor(
                                    _summary!.urgencyLevel,
                                  ),
                                ),
                              ),
                              child: Text(
                                _summary!.urgencyLevel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getUrgencyColor(
                                    _summary!.urgencyLevel,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Kartu Intisari
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withAlpha(12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.indigo.withAlpha(40),
                            ),
                          ),
                          child: Text(
                            _summary!.summary,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Poin Aksi (Action Items)
                        const Row(
                          children: [
                            Icon(
                              Icons.checklist_rtl,
                              size: 20,
                              color: Colors.indigo,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Langkah Tindak Lanjut Mahasiswa:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(
                          _summary!.actionItems.length,
                          (idx) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _summary!.actionItems[idx],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tombol Salin Ringkasan
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Salin Ringkasan AI'),
                            onPressed: () {
                              final clipboardContent =
                                  '${_summary!.summary}\n\nTindak Lanjut:\n${_summary!.actionItems.map((e) => '- $e').join('\n')}';
                              Clipboard.setData(
                                ClipboardData(text: clipboardContent),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Ringkasan AI disalin ke papan klip!',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
