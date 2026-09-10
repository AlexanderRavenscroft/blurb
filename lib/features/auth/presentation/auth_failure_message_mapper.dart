import 'package:blurb/features/auth/domain/auth_exception.dart';

abstract final class AuthFailureMessageMapper {
  static String forLogin(AuthExceptionCode code) {
    return switch (code) {
      AuthExceptionCode.invalidCredentials => 'Invalid email or password.',
      AuthExceptionCode.invalidEmail => 'Enter a valid email address.',
      AuthExceptionCode.emailNotConfirmed =>
        'Confirm your email before signing in.',
      AuthExceptionCode.userDisabled => 'This account has been disabled.',
      AuthExceptionCode.tooManyRequests =>
        'Too many attempts. Try again later.',
      AuthExceptionCode.network => 'Check your internet connection.',
      AuthExceptionCode.operationNotAllowed =>
        'Email sign-in is currently unavailable.',
      _ => 'Could not sign in. Try again.',
    };
  }

  static String forRegister(AuthExceptionCode code) {
    return switch (code) {
      AuthExceptionCode.emailAlreadyInUse =>
        'An account already exists for this email.',
      AuthExceptionCode.weakPassword => 'Choose a stronger password.',
      AuthExceptionCode.invalidEmail => 'Enter a valid email address.',
      AuthExceptionCode.tooManyRequests =>
        'Too many attempts. Try again later.',
      AuthExceptionCode.network => 'Check your internet connection.',
      AuthExceptionCode.operationNotAllowed =>
        'Account creation is currently unavailable.',
      _ => 'Could not create the account. Try again.',
    };
  }

  static String forSignOut(AuthExceptionCode code) {
    return switch (code) {
      AuthExceptionCode.network => 'Check your internet connection.',
      _ => 'Could not sign out. Try again.',
    };
  }

  static String forSocialSignIn(AuthExceptionCode code) {
    return switch (code) {
      AuthExceptionCode.tooManyRequests =>
        'Too many attempts. Try again later.',
      AuthExceptionCode.network => 'Check your internet connection.',
      AuthExceptionCode.operationNotAllowed =>
        'This sign-in provider is currently unavailable.',
      _ => 'Could not sign in. Try again.',
    };
  }
}
