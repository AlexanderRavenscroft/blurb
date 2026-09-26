import 'package:blurb/features/profile/domain/profile_exception.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_page_state.dart';

class ProfilePageCubit extends Cubit<ProfilePageState> {
  final ProfileRepository _profileRepository;

  ProfilePageCubit({required this._profileRepository})
    : super(const ProfilePageLoading());

  Future<void> load({
    required String profileId,
    required bool isOwnProfile,
  }) async {
    if (isClosed) return;
    emit(const ProfilePageLoading());

    try {
      final profile = await _profileRepository.getProfile(profileId);
      if (profile == null) {
        throw StateError('Profile no longer exists');
      }

      final isFollowing = isOwnProfile
          ? false
          : await _profileRepository.isFollowing(profileId);

      if (isClosed) return;
      emit(ProfilePageLoaded(profile: profile, isFollowing: isFollowing));
    } catch (error, stackTrace) {
      log.e('Profile page load failed', error: error, stackTrace: stackTrace);
      if (isClosed) return;
      emit(
        ProfilePageFailure(
          error is ProfileException ? error.code : ProfileExceptionCode.unknown,
        ),
      );
    }
  }

  Future<void> toggleFollow() async {
    final currentState = state;
    if (isClosed ||
        currentState is! ProfilePageLoaded ||
        currentState.isUpdatingFollow) {
      return;
    }

    final profile = currentState.profile;
    emit(currentState.copyWith(isUpdatingFollow: true));

    try {
      if (currentState.isFollowing) {
        await _profileRepository.unfollow(profile.id);
      } else {
        await _profileRepository.follow(profile.id);
      }
    } catch (error, stackTrace) {
      log.e('Follow update failed', error: error, stackTrace: stackTrace);
      if (isClosed) return;
      emit(
        currentState.copyWith(
          followErrorCode: error is ProfileException
              ? error.code
              : ProfileExceptionCode.unknown,
        ),
      );
      return;
    }

    if (isClosed) return;
    final followedState = currentState.copyWith(
      isFollowing: !currentState.isFollowing,
      isUpdatingFollow: true,
    );
    emit(followedState);

    try {
      final refreshedProfile = await _profileRepository.getProfile(profile.id);
      if (refreshedProfile == null) {
        throw StateError('Profile no longer exists');
      }

      if (isClosed) return;
      emit(
        followedState.copyWith(
          profile: refreshedProfile,
          isUpdatingFollow: false,
        ),
      );
    } catch (error, stackTrace) {
      log.e(
        'Profile refresh after follow update failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (isClosed) return;
      emit(followedState.copyWith(isUpdatingFollow: false));
    }
  }
}
