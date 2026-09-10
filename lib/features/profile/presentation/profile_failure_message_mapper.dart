import 'package:blurb/features/profile/domain/profile_exception.dart';

abstract final class ProfileFailureMessageMapper {
  static String forSave(ProfileExceptionCode code) {
    return switch (code) {
      ProfileExceptionCode.usernameTaken => 'This username is already taken.',
      ProfileExceptionCode.unknown =>
        'Could not save your profile. Please try again.',
    };
  }
}
