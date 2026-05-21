import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  // Save
  Future<void> saveLogin(String login) =>
      _storage.write(key: AppConstants.keyLogin, value: login);

  Future<void> savePeanutToken(String token) =>
      _storage.write(key: AppConstants.keyPeanutToken, value: token);

  Future<void> savePartnerToken(String token) =>
      _storage.write(key: AppConstants.keyPartnerToken, value: token);

  // Read
  Future<String?> getLogin() => _storage.read(key: AppConstants.keyLogin);

  Future<String?> getPeanutToken() =>
      _storage.read(key: AppConstants.keyPeanutToken);

  Future<String?> getPartnerToken() =>
      _storage.read(key: AppConstants.keyPartnerToken);

  // Clear all on logout
  Future<void> clearAll() => _storage.deleteAll();

  // Check if session exists
  Future<bool> hasSession() async {
    final login = await getLogin();
    final peanut = await getPeanutToken();
    final partner = await getPartnerToken();
    return login != null && peanut != null && partner != null;
  }
}
