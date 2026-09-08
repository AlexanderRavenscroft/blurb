part of 'register_cubit.dart';

@immutable
sealed class RegisterState {
  const RegisterState();
}

final class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

final class RegisterSubmitting extends RegisterState {
  const RegisterSubmitting();
}

final class RegisterFailure extends RegisterState {
  final AuthExceptionCode code;

  const RegisterFailure(this.code);
}
