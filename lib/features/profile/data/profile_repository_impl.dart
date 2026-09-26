import 'dart:async';
import 'dart:typed_data';

import 'package:blurb/features/profile/domain/profile_exception.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  static const _avatarBucket = 'avatars';
  static const _profileColumns =
      'id, username, full_name, avatar_url, bio, followers_count, following_count, posts_count';
  final _supabase = Supabase.instance.client;

  final _profileChanges = StreamController<UserProfile>.broadcast();

  @override
  Stream<UserProfile> get profileChanges => _profileChanges.stream;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select(_profileColumns)
        .eq('id', userId)
        .maybeSingle();

    return data == null ? null : _mapProfile(data);
  }

  @override
  Future<List<UserProfile>> getProfilesExcludingUser(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select(_profileColumns)
        .neq('id', userId);

    return data.map(_mapProfile).toList();
  }

  @override
  Future<void> saveProfile({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    Uint8List? avatarBytes,
    String? avatarExtension,
  }) async {
    try {
      final avatarUrl = avatarBytes == null
          ? null
          : await _uploadAvatar(
              userId: userId,
              bytes: avatarBytes,
              extension: avatarExtension,
            );

      final data = await _supabase
          .from('profiles')
          .upsert({
            'id': userId,
            'username': ?username,
            'full_name': ?fullName,
            'bio': ?bio,
            'avatar_url': ?avatarUrl,
          }, onConflict: 'id')
          .select(_profileColumns)
          .single();

      final profile = _mapProfile(data);
      _profileChanges.add(profile);
    } on PostgrestException catch (exception, stackTrace) {
      if (exception.code == '23505') {
        Error.throwWithStackTrace(
          const ProfileException(ProfileExceptionCode.usernameTaken),
          stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<String> _uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String? extension,
  }) async {
    final objectPath =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

    try {
      final bucket = _supabase.storage.from(_avatarBucket);
      await bucket.uploadBinary(objectPath, bytes);

      return bucket.getPublicUrl(objectPath);
    } on StorageException catch (exception, stackTrace) {
      log.e(
        'Avatar upload failed: ${exception.message} '
        '(status: ${exception.statusCode}, error: ${exception.error})',
        error: exception,
        stackTrace: stackTrace,
      );
      Error.throwWithStackTrace(
        const ProfileException(ProfileExceptionCode.avatarUploadFailed),
        stackTrace,
      );
    }
  }

  UserProfile _mapProfile(Map<String, dynamic> data) => UserProfile(
    id: data['id'] as String,
    username: data['username'] as String? ?? '',
    fullName: data['full_name'] as String? ?? '',
    bio: data['bio'] as String,
    avatarUrl: data['avatar_url'] as String?,
    followersCount: (data['followers_count'] as num).toInt(),
    followingCount: (data['following_count'] as num).toInt(),
    postsCount: (data['posts_count'] as num).toInt(),
  );

  @override
  Future<void> follow(String profileId) async {
    final currentUserId = _requireCurrentUserId();

    await _supabase
        .from('follows')
        .upsert(
          {'follower_id': currentUserId, 'followed_id': profileId},
          onConflict: 'follower_id,followed_id',
          ignoreDuplicates: true,
        );
  }

  @override
  Future<bool> isFollowing(String profileId) async {
    final currentUserId = _requireCurrentUserId();
    final relationship = await _supabase
        .from('follows')
        .select('follower_id')
        .eq('follower_id', currentUserId)
        .eq('followed_id', profileId)
        .maybeSingle();

    return relationship != null;
  }

  @override
  Future<void> unfollow(String profileId) async {
    final currentUserId = _requireCurrentUserId();

    await _supabase
        .from('follows')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('followed_id', profileId);
  }

  String _requireCurrentUserId() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('A signed-in user is required');
    }

    return userId;
  }
}
