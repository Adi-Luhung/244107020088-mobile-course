import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/network_errors.dart';

void main() {
  test('fromJson aman terhadap field yang hilang (Edge Case)', () {
    // Simulasi respons API cacat/kosong
    final Map<String, dynamic> jsonKosong = {};
    final post = Post.fromJson(jsonKosong);
    final comment = Comment.fromJson(jsonKosong);

    expect(post.id, 0);
    expect(post.title, '');
    expect(comment.postId, 0);
    expect(comment.name, '');
  });

  test('friendlyErrorMessage memetakan jenis badResponse secara akurat', () {
    final dioError = DioException(
      requestOptions: RequestOptions(path: '/posts'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/posts'),
        statusCode: 404,
      ),
    );

    final pesan = friendlyErrorMessage(dioError);
    expect(pesan, contains('404'));
  });
}
