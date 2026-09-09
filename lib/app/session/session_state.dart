part of 'session_cubit.dart';

@immutable
sealed class SessionState {
  const SessionState();
}

final class SessionChecking extends SessionState {
  const SessionChecking();
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

final class SessionNeedsProfile extends SessionState {
  final AuthUser user;

  const SessionNeedsProfile({required this.user});
}

final class SessionAuthenticated extends SessionState {
  final AuthUser user;
  final UserProfile profile;

  const SessionAuthenticated({required this.user, required this.profile});
}

final class SessionFailure extends SessionState {
  const SessionFailure();
}
