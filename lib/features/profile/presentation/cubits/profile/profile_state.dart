part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileSaving extends ProfileState {
  const ProfileSaving();
}

final class ProfileSaved extends ProfileState {
  final UserProfile profile;

  const ProfileSaved(this.profile);
}

final class ProfileFailure extends ProfileState {
  final ProfileExceptionCode code;

  const ProfileFailure(this.code);
}
