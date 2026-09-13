import 'package:blurb/features/profile/domain/profile_exception.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_form_state.dart';

class ProfileFormCubit extends Cubit<ProfileFormState> {
  final ProfileRepository _profileRepository;

  ProfileFormCubit({required this._profileRepository})
    : super(const ProfileFormInitial());

  Future<void> save({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    Uint8List? avatarBytes,
    String? avatarExtension,
  }) async {
    if (state is ProfileFormSaving) return;
    emit(const ProfileFormSaving());

    try {
      await _profileRepository.saveProfile(
        userId: userId,
        username: username?.trim(),
        fullName: fullName?.trim(),
        bio: bio?.trim(),
        avatarBytes: avatarBytes,
        avatarExtension: avatarExtension,
      );
      emit(const ProfileFormSaved());
    } on ProfileException catch (exception) {
      emit(ProfileFormFailure(exception.code));
    } catch (error, stackTrace) {
      log.e('Profile save failed', error: error, stackTrace: stackTrace);
      emit(const ProfileFormFailure(ProfileExceptionCode.unknown));
    }
  }
}
