import 'package:blurb/features/profile/domain/profile_exception.dart';

abstract final class ProfileFailureMessageMapper {
  static String forSave(ProfileExceptionCode code) {
    return switch (code) {
      ProfileExceptionCode.usernameTaken => 'This username is already taken.',
      ProfileExceptionCode.imageTooLarge =>
        'Choose a profile picture smaller than 2 MB.',
      ProfileExceptionCode.unsupportedImageType =>
        'Choose a JPEG, PNG, or WebP image.',
      ProfileExceptionCode.imageSelectionFailed =>
        'Could not select the image. Please try again.',
      ProfileExceptionCode.avatarUploadFailed =>
        'Could not upload your profile picture. Please try again.',
      ProfileExceptionCode.avatarPermissionDenied =>
        'Allow camera or photo access to choose a profile picture.',
      ProfileExceptionCode.unknown =>
        'Could not save your profile. Please try again.',
    };
  }
}
