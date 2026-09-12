enum ProfileExceptionCode {
  usernameTaken,
  imageTooLarge,
  unsupportedImageType,
  imageSelectionFailed,
  avatarUploadFailed,
  avatarPermissionDenied,
  unknown,
}

final class ProfileException implements Exception {
  final ProfileExceptionCode code;

  const ProfileException(this.code);
}
