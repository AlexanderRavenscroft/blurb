part of 'profile_page_cubit.dart';

@immutable
sealed class ProfilePageState {
  const ProfilePageState();
}

final class ProfilePageLoading extends ProfilePageState {
  const ProfilePageLoading();
}

final class ProfilePageFailure extends ProfilePageState {
  final ProfileExceptionCode code;

  const ProfilePageFailure(this.code);
}

final class ProfilePageLoaded extends ProfilePageState {
  final UserProfile profile;
  final bool isFollowing;
  final bool isUpdatingFollow;
  final ProfileExceptionCode? followErrorCode;

  const ProfilePageLoaded({
    required this.profile,
    this.isFollowing = false,
    this.isUpdatingFollow = false,
    this.followErrorCode,
  });

  ProfilePageLoaded copyWith({
    UserProfile? profile,
    bool? isFollowing,
    bool? isUpdatingFollow,
    ProfileExceptionCode? followErrorCode,
  }) => ProfilePageLoaded(
    profile: profile ?? this.profile,
    isFollowing: isFollowing ?? this.isFollowing,
    isUpdatingFollow: isUpdatingFollow ?? this.isUpdatingFollow,
    followErrorCode: followErrorCode,
  );
}
