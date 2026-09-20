import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_client.dart';
import '../data/repositories/post_repository.dart';
import '../data/paged_posts.dart';
import 'package:dio/dio.dart';


final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.watch(dioProvider));
});

class PagedPostsNotifier extends Notifier<PagedPostsState> {
  @override
  PagedPostsState build() {
    Future.microtask(() => loadFirstPage());
    return const PagedPostsState();
  }

  Future<void> loadFirstPage() async {
    state = const PagedPostsState(items: [], page: 1, isLoadingMore: false);
    try {
      final repo = ref.read(postRepositoryProvider);
      final items = await repo.fetchPostsPage(page: 1, limit: 20);
      state = state.copyWith(items: items, hasMore: items.length == 20);
    } catch (e) {
      state = state.copyWith(error: e, hasMore: false);
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final repo = ref.read(postRepositoryProvider);
      final nextItems = await repo.fetchPostsPage(page: nextPage, limit: 20);
      
      state = state.copyWith(
        items: [...state.items, ...nextItems],
        page: nextPage,
        isLoadingMore: false,
        hasMore: nextItems.length == 20,
      );
    } catch (e) {
      state = state.copyWith(error: e, isLoadingMore: false);
    }
  }
}

final pagedPostsProvider =
    NotifierProvider<PagedPostsNotifier, PagedPostsState>(PagedPostsNotifier.new);
