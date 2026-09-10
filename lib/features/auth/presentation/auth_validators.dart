abstract final class AuthValidators {
  static const int minimumPasswordLength = 6;
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? loginEmail(String? value) {
    return _email(value);
  }

  static String? registrationEmail(String? value) {
    return _email(value);
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }

    return null;
  }

  static String? registrationPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }

    if (!hasMinimumPasswordLength(value)) {
      return 'Password must be at least $minimumPasswordLength characters.';
    }
    return null;
  }

  static bool hasMinimumPasswordLength(String value) {
    return value.length >= minimumPasswordLength;
  }

  static String? _email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email cannot be empty.';
    }

    if (!_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }
}
