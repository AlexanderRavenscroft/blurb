import 'dart:async';
import 'dart:typed_data';

import 'package:blurb/features/profile/domain/profile_exception.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  static const _avatarBucket = 'avatars';
  final _supabase = Supabase.instance.client;

  final _profileChanges = StreamController<UserProfile>.broadcast();

  @override
  Stream<UserProfile> get profileChanges => _profileChanges.stream;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select('id, username, full_name, avatar_url, bio')
        .eq('id', userId)
        .maybeSingle();

    return data == null ? null : _mapProfile(data);
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
          .select('id, username, full_name, avatar_url, bio')
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
  );
}
