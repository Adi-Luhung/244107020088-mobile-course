import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_assistant_providers.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  final List<String> _quickPrompts = [
    'Jadwal UTS?',
    'Syarat Beasiswa?',
    'Workshop Flutter?',
    'Batas Revisi KRS?',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendCurrentMessage({bool isVoice = false}) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(aiChatProvider.notifier).sendMessage(text, isVoice: isVoice);
    _scrollToBottom();
  }

  void _sendQuickPrompt(String prompt) {
    ref.read(aiChatProvider.notifier).sendMessage(prompt);
    _scrollToBottom();
  }

  void _simulateVoiceInput() {
    final isRecording = ref.read(voiceRecordingProvider);
    if (!isRecording) {
      ref.read(voiceRecordingProvider.notifier).start();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.mic, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Mendengarkan suara... (Speech-to-Text Aktif)'),
            ],
          ),
          duration: Duration(milliseconds: 1400),
          backgroundColor: Colors.indigo,
        ),
      );

      // Simulasi hasil transkripsi suara setelah 1 detik
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        ref.read(voiceRecordingProvider.notifier).stop();
        _controller.text = 'Kapan jadwal pelaksanaan UTS luring di Gedung TI?';
        _sendCurrentMessage(isVoice: true);
      });
    } else {
      ref.read(voiceRecordingProvider.notifier).stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final isRecording = ref.watch(voiceRecordingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asisten AI Kampus',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'JTI Polinema Smart Academic Bot',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Bersihkan Riwayat Chat',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(aiChatProvider.notifier).clearHistory();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Prompts Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickPrompts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = _quickPrompts[index];
                  return ActionChip(
                    label: Text(prompt, style: const TextStyle(fontSize: 12)),
                    avatar: const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: Colors.indigo,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    onPressed: () => _sendQuickPrompt(prompt),
                  );
                },
              ),
            ),
          ),
          // Chat Messages List
          Expanded(
            child: chatState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageItem(msg);
                  },
                );
              },
            ),
          ),
          // Voice Recording Indicator Bar
          if (isRecording)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: Colors.redAccent.withAlpha(25),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Mendengarkan suara... Ucapkan pertanyaan Anda',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Speech-to-Text Mic Button
                  IconButton(
                    key: const Key('voice_input_button'),
                    icon: Icon(
                      isRecording ? Icons.mic : Icons.mic_none,
                      color: isRecording ? Colors.redAccent : Colors.indigo,
                    ),
                    tooltip: 'Input Suara (Speech-to-Text)',
                    onPressed: _simulateVoiceInput,
                  ),
                  Expanded(
                    child: TextField(
                      key: const Key('chat_input_field'),
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Tanyakan ke Asisten AI...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendCurrentMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send Button
                  IconButton(
                    key: const Key('send_message_button'),
                    icon: const Icon(Icons.send_rounded, color: Colors.indigo),
                    tooltip: 'Kirim Pertanyaan',
                    onPressed: () => _sendCurrentMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(dynamic msg) {
    final isUser = msg.isUser as bool;
    final isVoice = (msg.isVoiceInput ?? false) as bool;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.auto_awesome, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? Colors.indigo : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (isVoice) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mic,
                          size: 14,
                          color: isUser ? Colors.white70 : Colors.indigo,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Transkripsi Suara',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: isUser ? Colors.white70 : Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    msg.text as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : Colors.black87,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
