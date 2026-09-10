import 'package:blurb/features/profile/domain/profile_exception.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit({required this._profileRepository})
    : super(const ProfileInitial());

  Future<void> save({
    required String userId,
    required String username,
    required String fullName,
  }) async {
    if (state is ProfileSaving) return;
    emit(const ProfileSaving());

    try {
      final profile = await _profileRepository.saveProfile(
        userId: userId,
        username: username.trim(),
        fullName: fullName.trim(),
      );
      if (!isClosed) emit(ProfileSaved(profile));
    } on ProfileException catch (exception) {
      if (isClosed) return;
      emit(ProfileFailure(exception.code));
    } catch (error, stackTrace) {
      log.e('Profile save failed', error: error, stackTrace: stackTrace);
      if (!isClosed) {
        emit(const ProfileFailure(ProfileExceptionCode.unknown));
      }
    }
  }
}
