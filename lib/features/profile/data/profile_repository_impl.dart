import 'package:blurb/features/profile/domain/profile_exception.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select('id, username, full_name, avatar_url')
        .eq('id', userId)
        .maybeSingle();

    return data == null ? null : _mapProfile(data);
  }

  @override
  Future<UserProfile> saveProfile({
    required String userId,
    required String username,
    required String fullName,
  }) async {
    try {
      final data = await _supabase
          .from('profiles')
          .upsert({
            'id': userId,
            'username': username,
            'full_name': fullName,
          }, onConflict: 'id')
          .select('id, username, full_name, avatar_url')
          .single();

      return _mapProfile(data);
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

  UserProfile _mapProfile(Map<String, dynamic> data) => UserProfile(
    id: data['id'] as String,
    username: data['username'] as String? ?? '',
    fullName: data['full_name'] as String? ?? '',
    avatarUrl: data['avatar_url'] as String?,
  );
}
