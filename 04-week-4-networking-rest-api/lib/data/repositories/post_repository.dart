import 'package:dio/dio.dart';
import '../models/post.dart';

class PostRepository {
  final Dio _dio;
  PostRepository(this._dio);

  // Fungsi penarik data untuk pagination scroll otomatis
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    final response = await _dio.get(
      '/posts',
      queryParameters: {'_page': page, '_limit': limit},
    );
    
    final data = response.data ?? [];
    return (data as List)
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
