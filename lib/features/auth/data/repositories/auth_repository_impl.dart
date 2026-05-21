import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_request_model.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<AuthEntity> login(String login, String password) async {
    final response = await remoteDataSource.login(
      AuthRequestModel(login: login, password: password),
    );

    final entity = AuthEntity(
      login: login,
      peanutToken: response.peanutToken!,
      partnerToken: response.partnerToken!,
    );

    // Persist session
    await secureStorage.saveLogin(login);
    await secureStorage.savePeanutToken(response.peanutToken!);
    await secureStorage.savePartnerToken(response.partnerToken!);

    return entity;
  }

  @override
  Future<AuthEntity?> getStoredSession() async {
    final hasSession = await secureStorage.hasSession();
    if (!hasSession) return null;

    return AuthEntity(
      login: (await secureStorage.getLogin())!,
      peanutToken: (await secureStorage.getPeanutToken())!,
      partnerToken: (await secureStorage.getPartnerToken())!,
    );
  }

  @override
  Future<void> logout() => secureStorage.clearAll();
}
