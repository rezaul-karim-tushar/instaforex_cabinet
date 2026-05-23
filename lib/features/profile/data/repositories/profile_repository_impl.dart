import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileEntity> getProfile({
    required String login,
    required String peanutToken,
  }) async {
    // Fetch both in parallel — phone is non-critical
    final results = await Future.wait([
      remoteDataSource.getAccountInformation(login: login, token: peanutToken),
      remoteDataSource.getLastFourPhone(login: login, token: peanutToken),
    ]);

    final info = results[0] as Map<String, dynamic>;
    final lastFour = results[1] as String;

    return ProfileEntity(
      login: login,
      firstName: _str(info, ['FirstName', 'firstName', 'first_name']),
      lastName: _str(info, ['LastName', 'lastName', 'last_name']),
      email: _str(info, ['Email', 'email']),
      country: _str(info, ['Country', 'country']),
      currency: _str(info, ['Currency', 'currency']),
      lastFourPhone: lastFour,
    );
  }

  // Safely extract string trying multiple possible key names
  String _str(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map[key] != null && map[key].toString().isNotEmpty) {
        return map[key].toString();
      }
    }
    return '';
  }
}
