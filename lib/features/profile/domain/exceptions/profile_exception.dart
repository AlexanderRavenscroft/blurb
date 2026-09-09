enum ProfileExceptionCode { usernameTaken, unknown }

final class ProfileException implements Exception {
  final ProfileExceptionCode code;

  const ProfileException(this.code);
}
