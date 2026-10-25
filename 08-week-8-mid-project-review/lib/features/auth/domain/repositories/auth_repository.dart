import '../../../../core/failures.dart';

abstract class AuthRepository {
  Future<({bool success, Failure? failure})> login(
    String email,
    String password,
  );
  Future<void> logout();
  Future<String?> getAccessToken();
}
