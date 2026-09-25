part of 'profile_list_cubit.dart';

@immutable
sealed class ProfileListState {
  const ProfileListState();
}

final class ProfileListLoading extends ProfileListState {
  const ProfileListLoading();
}

final class ProfileListLoaded extends ProfileListState {
  final List<UserProfile> profiles;

  const ProfileListLoaded(this.profiles);
}

final class ProfileListFailure extends ProfileListState {
  final ProfileExceptionCode code;

  const ProfileListFailure(this.code);
}
