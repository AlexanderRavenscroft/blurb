part of 'auth_cubit.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthChecking extends AuthState {
  const AuthChecking();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthAuthenticated extends AuthState {
  final AuthUser user;

  const AuthAuthenticated({required this.user});
}
