import 'package:blurb/config/app_config.dart';
import 'package:blurb/features/auth/domain/auth_exception.dart';
import 'package:blurb/features/auth/domain/auth_repository.dart';
import 'package:blurb/features/auth/domain/auth_user.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepositoryImpl implements AuthRepository {
  final supabaseInstance = supabase.Supabase.instance.client;

  @override
  Stream<AuthUser?> watchUser() {
    return supabaseInstance.auth.onAuthStateChange.map(
      (data) => _mapUser(data.session?.user),
    );
  }

  AuthUser? _mapUser(supabase.User? user) {
    if (user == null) return null;

    final email = user.email;

    if (email == null) {
      throw StateError('An email/password user must have an email address.');
    }

    return AuthUser(id: user.id, email: email);
  }

  @override
  Future<void> logIn({required String email, required String password}) async {
    try {
      await supabaseInstance.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on supabase.AuthException catch (exception, stackTrace) {
      Error.throwWithStackTrace(
        _mapException(exception, stackTrace),
        stackTrace,
      );
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await supabaseInstance.auth.signUp(email: email, password: password);
    } on supabase.AuthException catch (exception, stackTrace) {
      Error.throwWithStackTrace(
        _mapException(exception, stackTrace),
        stackTrace,
      );
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    const webClientId = AppConfig.googleWebClientId;
    const iosClientId = AppConfig.googleIosClientId;

    try {
      final signIn = GoogleSignIn.instance;
      await signIn.initialize(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      final googleAccount = await signIn.authenticate();
      final idToken = googleAccount.authentication.idToken;

      if (idToken == null) {
        throw StateError('Google Sign-In returned no ID token.');
      }

      await supabaseInstance.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
      );
    } on supabase.AuthException catch (exception, stackTrace) {
      Error.throwWithStackTrace(
        _mapException(exception, stackTrace),
        stackTrace,
      );
    }
  }

  @override
  Future<void> signInWithFacebook() async {
    try {
      await supabaseInstance.auth.signInWithOAuth(
        supabase.OAuthProvider.facebook,
        redirectTo: AppConfig.authRedirectUrl,
        authScreenLaunchMode: supabase.LaunchMode.externalApplication,
      );
    } on supabase.AuthException catch (exception, stackTrace) {
      Error.throwWithStackTrace(
        _mapException(exception, stackTrace),
        stackTrace,
      );
    }
  }

  @override
  Future<void> signInWithDiscord() async {
    try {
      await supabaseInstance.auth.signInWithOAuth(
        supabase.OAuthProvider.discord,
        redirectTo: AppConfig.authRedirectUrl,
        authScreenLaunchMode: supabase.LaunchMode.externalApplication,
      );
    } on supabase.AuthException catch (exception, stackTrace) {
      Error.throwWithStackTrace(
        _mapException(exception, stackTrace),
        stackTrace,
      );
    }
  }

  AuthException _mapException(
    supabase.AuthException exception,
    StackTrace stackTrace,
  ) {
    if (exception is supabase.AuthRetryableFetchException &&
        exception.statusCode == null) {
      return const AuthException(AuthExceptionCode.network);
    }
    switch (exception.code) {
      case 'invalid_credentials':
      case 'user_not_found':
        return const AuthException(AuthExceptionCode.invalidCredentials);
      case 'email_address_invalid':
        return const AuthException(AuthExceptionCode.invalidEmail);
      case 'email_exists':
      case 'user_already_exists':
        return const AuthException(AuthExceptionCode.emailAlreadyInUse);
      case 'email_not_confirmed':
        return const AuthException(AuthExceptionCode.emailNotConfirmed);
      case 'weak_password':
        return const AuthException(AuthExceptionCode.weakPassword);
      case 'user_banned':
        return const AuthException(AuthExceptionCode.userDisabled);
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return const AuthException(AuthExceptionCode.tooManyRequests);
      case 'signup_disabled':
      case 'email_provider_disabled':
      case 'provider_disabled':
        return const AuthException(AuthExceptionCode.operationNotAllowed);
      default:
        log.e(
          'Unhandled Supabase Auth error: ${exception.code} (HTTP ${exception.statusCode})',
          error: exception,
          stackTrace: stackTrace,
        );
        return const AuthException(AuthExceptionCode.unknown);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseInstance.auth.signOut();
    } on supabase.AuthException catch (exception, stackTrace) {
      Error.throwWithStackTrace(
        _mapException(exception, stackTrace),
        stackTrace,
      );
    }
  }
}
