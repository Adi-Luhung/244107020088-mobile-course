import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/post_provider.dart';
import '../data/network_errors.dart';
import 'post_tile.dart';

class PostListPage extends ConsumerStatefulWidget {
  const PostListPage({super.key});

  @override
  ConsumerState<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends ConsumerState<PostListPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
        ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Infinite Scroll'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(pagedPostsProvider.notifier).loadFirstPage(),
          )
        ],
      ),
      body: Builder(
        builder: (context) {
          // 1. Kondisi Pertama Kali Memuat Data & Error
          if (state.error != null && state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(friendlyErrorMessage(state.error!), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.read(pagedPostsProvider.notifier).loadFirstPage(),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 2. Kondisi Loading Pertama Kali
          if (state.items.isEmpty && state.page == 1) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Kondisi Sukses Menampilkan List Data
          return RefreshIndicator(
            onRefresh: () => ref.read(pagedPostsProvider.notifier).loadFirstPage(),
            child: ListView.builder(
              controller: _controller,
              itemCount: state.items.length + 1,
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  if (state.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!state.hasMore && state.items.isNotEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('Semua data telah dimuat.')),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return PostTile(post: state.items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
