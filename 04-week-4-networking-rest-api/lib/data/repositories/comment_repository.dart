import 'package:dio/dio.dart';
import '../models/comment.dart';

class CommentRepository {
  final Dio _dio;
  CommentRepository(this._dio);

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get(
      '/comments',
      queryParameters: {'postId': postId},
    );
    final data = response.data ?? [];
    return (data as List)
        .map((json) => Comment.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
