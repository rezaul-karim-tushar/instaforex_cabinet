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

    final partnerToken = response.partnerToken!;

    // Use partner token for peanut calls since peanut auth endpoint
    // returns 404 — partner token works for ClientCabinetBasic endpoints
    final entity = AuthEntity(
      login: login,
      peanutToken: partnerToken,
      partnerToken: partnerToken,
    );

    await secureStorage.saveLogin(login);
    await secureStorage.savePeanutToken(partnerToken);
    await secureStorage.savePartnerToken(partnerToken);

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
