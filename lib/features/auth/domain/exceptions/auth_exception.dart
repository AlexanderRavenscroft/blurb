enum AuthExceptionCode {
  invalidCredentials,
  invalidEmail,
  emailAlreadyInUse,
  emailNotConfirmed,
  weakPassword,
  userDisabled,
  tooManyRequests,
  network,
  operationNotAllowed,
  unknown,
}

final class AuthException implements Exception {
  final AuthExceptionCode code;

  const AuthException(this.code);
}
