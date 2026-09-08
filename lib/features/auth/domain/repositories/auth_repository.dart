import 'package:blurb/features/auth/domain/entities/auth_user.dart';

abstract interface class AuthRepository {
  Stream<AuthUser?> watchUser();

  Future<void> logIn({required String email, required String password});

  Future<void> register({
    required String username,
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signInWithFacebook();

  Future<void> signOut();
}
