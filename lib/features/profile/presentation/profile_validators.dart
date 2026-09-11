abstract final class ProfileValidators {
  static const int maximumBioLength = 120;

  static final RegExp _usernamePattern = RegExp(r'^[a-z0-9_]+$');

  static String? username(String? value) {
    final username = (value ?? '').trim();

    if (username.length < 3 || username.length > 12) {
      return 'Username must be between 3 and 12 characters.';
    }
    if (!_usernamePattern.hasMatch(username)) {
      return 'Use only lowercase letters, numbers, and underscores.';
    }
    return null;
  }

  static String? fullName(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Enter your full name.';
    }
    return null;
  }

  static String? bio(String? value) {
    if ((value ?? '').trim().length > maximumBioLength) {
      return 'Bio cannot exceed $maximumBioLength characters.';
    }
    return null;
  }
}
