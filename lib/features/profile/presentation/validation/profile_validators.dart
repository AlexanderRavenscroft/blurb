abstract final class ProfileValidators {
  static String? username(String? value) {
    if ((value ?? '').trim().length < 3) {
      return 'Enter a username with at least 3 characters.';
    }
    return null;
  }

  static String? fullName(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Enter your full name.';
    }
    return null;
  }
}
