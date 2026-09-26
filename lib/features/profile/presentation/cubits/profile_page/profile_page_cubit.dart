import 'dart:async';

import 'package:blurb/features/profile/domain/profile_exception.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_page_state.dart';

class ProfilePageCubit extends Cubit<ProfilePageState> {
  final ProfileRepository _profileRepository;
  StreamSubscription<UserProfile?>? _profileSubscription;

  ProfilePageCubit({required this._profileRepository})
    : super(const ProfilePageLoading());

  Future<void> load({
    required String profileId,
    required bool isOwnProfile,
  }) async {
    if (isClosed) return;
    emit(const ProfilePageLoading());

    try {
      await _profileSubscription?.cancel();
      if (isClosed) return;
      final isFollowing = isOwnProfile
          ? false
          : await _profileRepository.isFollowing(profileId);
      if (isClosed) return;

      _profileSubscription = _profileRepository.watchProfile(profileId).listen((
        profile,
      ) {
        if (isClosed) return;
        if (profile == null) {
          emit(const ProfilePageFailure(ProfileExceptionCode.unknown));
          return;
        }
        final currentState = state;
        emit(
          currentState is ProfilePageLoaded
              ? currentState.copyWith(profile: profile)
              : ProfilePageLoaded(profile: profile, isFollowing: isFollowing),
        );
      }, onError: _onLoadError);
    } catch (error, stackTrace) {
      if (isClosed) return;
      _onLoadError(error, stackTrace);
    }
  }

  void _onLoadError(Object error, StackTrace stackTrace) {
    log.e('Profile load failed', error: error, stackTrace: stackTrace);
    if (isClosed || state is ProfilePageLoaded) return;
    emit(
      ProfilePageFailure(
        error is ProfileException ? error.code : ProfileExceptionCode.unknown,
      ),
    );
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

      if (isClosed) return;
      final latestState = state;
      if (latestState is! ProfilePageLoaded) return;
      emit(
        latestState.copyWith(
          isFollowing: !currentState.isFollowing,
          isUpdatingFollow: false,
        ),
      );
    } catch (error, stackTrace) {
      log.e('Follow update failed', error: error, stackTrace: stackTrace);
      if (isClosed) return;
      final latestState = state;
      if (latestState is! ProfilePageLoaded) return;
      emit(
        latestState.copyWith(
          isUpdatingFollow: false,
          followErrorCode: error is ProfileException
              ? error.code
              : ProfileExceptionCode.unknown,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _profileSubscription?.cancel();
    await super.close();
  }
}
