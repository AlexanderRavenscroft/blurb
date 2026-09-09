import 'package:blurb/features/profile/domain/entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);

  Future<UserProfile> saveProfile({
    required String userId,
    required String username,
    required String fullName,
  });
}
