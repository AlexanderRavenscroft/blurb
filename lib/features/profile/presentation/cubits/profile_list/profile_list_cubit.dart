import 'package:blurb/features/profile/domain/profile_exception.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_list_state.dart';

class ProfileListCubit extends Cubit<ProfileListState> {
  final ProfileRepository _profileRepository;

  ProfileListCubit({required this._profileRepository})
    : super(const ProfileListLoading());

  Future<void> loadProfiles({required String userId}) async {
    emit(const ProfileListLoading());
    try {
      final profiles = await _profileRepository.getProfilesExcludingUser(
        userId,
      );
      emit(ProfileListLoaded(profiles));
    } catch (error, stackTrace) {
      log.e('Profile list load failed', error: error, stackTrace: stackTrace);
      emit(const ProfileListFailure(ProfileExceptionCode.unknown));
    }
  }
}
