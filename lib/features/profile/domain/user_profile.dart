class UserProfile {
  final String id;
  final String username;
  final String fullName;
  final String bio;
  final String? avatarUrl;
  final int followersCount;
  final int followingCount;
  final int postsCount;

  const UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.bio,
    this.avatarUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
  });

  bool get isComplete =>
      username.trim().length >= 3 && fullName.trim().isNotEmpty;
}
