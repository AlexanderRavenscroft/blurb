part of 'social_auth_cubit.dart';

@immutable
sealed class SocialAuthState {
  const SocialAuthState();
}

final class SocialAuthInitial extends SocialAuthState {
  const SocialAuthInitial();
}

final class SocialAuthSubmitting extends SocialAuthState {
  const SocialAuthSubmitting();
}

final class SocialAuthFailure extends SocialAuthState {
  final AuthExceptionCode code;

  const SocialAuthFailure(this.code);
}
