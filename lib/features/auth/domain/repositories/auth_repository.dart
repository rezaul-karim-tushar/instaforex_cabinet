import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(String login, String password);
  Future<AuthEntity?> getStoredSession();
  Future<void> logout();
}
