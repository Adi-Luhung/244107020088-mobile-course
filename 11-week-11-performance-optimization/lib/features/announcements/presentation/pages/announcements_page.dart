import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai_assistant/presentation/pages/ai_chat_page.dart';
import '../providers/announcements_providers.dart';
import '../widgets/announcement_card_item.dart';

class AnnouncementsPage extends ConsumerStatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  ConsumerState<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends ConsumerState<AnnouncementsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(filteredAnnouncementsProvider);
    final currentQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Akademik'),
        actions: [
          IconButton(
            key: const Key('ai_assistant_appbar_button'),
            tooltip: 'Tanya Asisten AI',
            icon: const Icon(Icons.auto_awesome, color: Colors.indigo),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiChatPage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Segarkan Data',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(announcementsStateProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bar Pencarian Judul / Konten
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              key: const Key('search_text_field'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengumuman...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: currentQuery.isNotEmpty
                    ? IconButton(
                        key: const Key('clear_search_button'),
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      )
                    : null,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).setQuery(value);
              },
            ),
          ),
          // Daftar Pengumuman atau Status State
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Terjadi Kesalahan: ${error.toString().replaceAll('Exception: ', '')}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(announcementsStateProvider),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (announcements) {
                // Empty state ketika hasil pencarian atau data awal kosong
                if (announcements.isEmpty) {
                  final isSearching = currentQuery.trim().isNotEmpty;
                  return Center(
                    key: const Key('empty_state_container'),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSearching ? Icons.search_off : Icons.inbox,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isSearching
                                ? 'Tidak ditemukan pengumuman untuk "$currentQuery"'
                                : 'Belum ada catatan pengumuman.',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isSearching) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Coba gunakan kata kunci pencarian yang lain.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Paksa refresh dari remote/db dengan invalidasi cache
                    await ref
                        .read(announcementRepositoryProvider)
                        .fetchAnnouncements(forceRefresh: true);
                    ref.invalidate(announcementsStateProvider);
                  },
                  child: ListView.builder(
                    itemCount: announcements.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false, // Diisolasi per item di AnnouncementCardItem
                    itemBuilder: (context, index) {
                      return AnnouncementCardItem(
                        announcement: announcements[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('ai_chat_fab'),
        icon: const Icon(Icons.smart_toy),
        label: const Text('Tanya AI'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiChatPage()),
          );
        },
      ),
    );
  }
}
