part of 'login_cubit.dart';

@immutable
sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

final class LoginFailure extends LoginState {
  final AuthExceptionCode code;

  const LoginFailure(this.code);
}
