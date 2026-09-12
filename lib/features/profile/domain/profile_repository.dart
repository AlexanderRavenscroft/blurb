import 'dart:typed_data';

import 'package:blurb/features/profile/domain/user_profile.dart';

abstract interface class ProfileRepository {
  Stream<UserProfile> get profileChanges;

  Future<UserProfile?> getProfile(String userId);

  Future<void> saveProfile({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    Uint8List? avatarBytes,
    String? avatarExtension,
  });
}
