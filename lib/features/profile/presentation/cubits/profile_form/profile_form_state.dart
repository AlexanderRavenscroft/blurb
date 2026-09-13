part of 'profile_form_cubit.dart';

@immutable
sealed class ProfileFormState {
  const ProfileFormState();
}

final class ProfileFormInitial extends ProfileFormState {
  const ProfileFormInitial();
}

final class ProfileFormSaving extends ProfileFormState {
  const ProfileFormSaving();
}

final class ProfileFormSaved extends ProfileFormState {
  const ProfileFormSaved();
}

final class ProfileFormFailure extends ProfileFormState {
  final ProfileExceptionCode code;

  const ProfileFormFailure(this.code);
}
