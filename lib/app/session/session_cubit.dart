import 'dart:async';

import 'package:blurb/features/auth/domain/auth_repository.dart';
import 'package:blurb/features/auth/domain/auth_user.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  late final StreamSubscription<AuthUser?> _authSubscription;
  late final StreamSubscription<UserProfile> _profileSubscription;

  SessionCubit({
    required this._authRepository,
    required this._profileRepository,
  }) : super(const SessionChecking()) {
    _authSubscription = _authRepository
        .watchUser()
        .distinct((previous, next) => previous?.id == next?.id)
        .listen(
          _onUserChanged,
          onError: (Object error, StackTrace stackTrace) {
            log.e(
              'Auth state stream failed',
              error: error,
              stackTrace: stackTrace,
            );
            if (state is SessionChecking) {
              emit(const SessionUnauthenticated());
            }
          },
        );
    _profileSubscription = _profileRepository.profileChanges.listen((profile) {
      final user = switch (state) {
        SessionAuthenticated s => s.user,
        SessionNeedsProfile s => s.user,
        _ => null,
      };

      if (user == null || user.id != profile.id) return;

      emit(
        profile.isComplete
            ? SessionAuthenticated(user: user, profile: profile)
            : SessionNeedsProfile(user: user),
      );
    });
  }

  Future<void> _onUserChanged(AuthUser? user) async {
    if (user == null) {
      emit(const SessionUnauthenticated());
      return;
    }

    emit(const SessionChecking());

    try {
      final profile = await _profileRepository.getProfile(user.id);

      if (profile == null || !profile.isComplete) {
        emit(SessionNeedsProfile(user: user));
      } else {
        emit(SessionAuthenticated(user: user, profile: profile));
      }
    } catch (error, stackTrace) {
      log.e('Profile load failed', error: error, stackTrace: stackTrace);
      emit(const SessionFailure());
    }
  }

  Future<void> signOut() => _authRepository.signOut();

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    await _profileSubscription.cancel();
    await super.close();
  }
}
