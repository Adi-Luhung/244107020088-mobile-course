import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<String?> readAccess() async {
    try {
      return await _storage.read(key: _accessKey);
    } catch (e) {
      await clear();
      return null;
    }
  }

  Future<String?> readRefresh() async {
    try {
      return await _storage.read(key: _refreshKey);
    } catch (e) {
      await clear();
      return null;
    }
  }
  
  Future<void> clear() => _storage.deleteAll();
}
