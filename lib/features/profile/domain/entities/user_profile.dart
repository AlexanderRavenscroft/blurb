class UserProfile {
  final String id;
  final String username;
  final String fullName;

  const UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
  });

  bool get isComplete =>
      username.trim().length >= 3 && fullName.trim().isNotEmpty;
}
