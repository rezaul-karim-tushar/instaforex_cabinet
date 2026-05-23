import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile({
    required String login,
    required String peanutToken,
  });
}
