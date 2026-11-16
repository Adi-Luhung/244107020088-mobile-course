import '../../domain/repositories/auth_repository.dart';
import '../token_store.dart';
import '../../../../core/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._tokenStore);
  final TokenStore _tokenStore;

  @override
  Future<({bool success, Failure? failure})> login(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      return (
        success: false,
        failure: const NetworkFailure('Email atau kata sandi tidak valid'),
      );
    }
    await _tokenStore.save(access: 'access-$email', refresh: 'refresh-$email');
    return (success: true, failure: null);
  }

  @override
  Future<void> logout() => _tokenStore.clear();

  @override
  Future<String?> getAccessToken() => _tokenStore.readAccess();
}
