import 'dart:async';

import 'package:blurb/features/auth/domain/entities/auth_user.dart';
import 'package:blurb/features/auth/domain/repositories/auth_repository.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<AuthUser?> _authSubscription;

  SessionCubit({required this._authRepository})
    : super(const SessionChecking()) {
    _authSubscription = _authRepository.watchUser().listen(
      _onUserChanged,
      onError: (Object error, StackTrace stackTrace) {
        log.e('Auth state stream failed', error: error, stackTrace: stackTrace);
        if (state is SessionChecking) emit(const SessionUnauthenticated());
      },
    );
  }

  void _onUserChanged(AuthUser? user) {
    final currentState = state;

    if (user == null) {
      emit(const SessionUnauthenticated());
    } else if (currentState is SessionNeedsProfile &&
        currentState.user.id == user.id) {
      emit(SessionNeedsProfile(user: user));
    } else {
      emit(SessionAuthenticated(user: user));
    }
  }

  // Temporary routing state until profile persistence is added.
  void requireProfileSetup() {
    final currentState = state;
    if (currentState is SessionAuthenticated) {
      emit(SessionNeedsProfile(user: currentState.user));
    }
  }

  void completeProfileSetup() {
    final currentState = state;
    if (currentState is SessionNeedsProfile) {
      emit(SessionAuthenticated(user: currentState.user));
    }
  }

  Future<void> signOut() => _authRepository.signOut();

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    await super.close();
  }
}
