import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage;

  const TokenStorage(this._storage);

  static const String _tokenKey = 'qishloq_ai_mobile_token';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearAccessToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
