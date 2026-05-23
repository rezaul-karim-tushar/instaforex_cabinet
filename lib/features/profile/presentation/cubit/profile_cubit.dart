import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/errors/failures.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  ProfileCubit({required this.profileRepository}) : super(ProfileInitial());

  Future<void> loadProfile({
    required String login,
    required String peanutToken,
  }) async {
    emit(ProfileLoading());
    try {
      final profile = await profileRepository.getProfile(
        login: login,
        peanutToken: peanutToken,
      );
      emit(ProfileLoaded(profile));
    } on NetworkFailure catch (e) {
      emit(ProfileError(e.message));
    } on ServerFailure catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(const ProfileError('Failed to load profile.'));
    }
  }
}
