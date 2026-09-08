import 'dart:async';

import 'package:blurb/features/auth/domain/entities/auth_user.dart';
import 'package:blurb/features/auth/domain/repositories/auth_repository.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<AuthUser?> _authSubscription;

  AuthCubit({required this._authRepository}) : super(const AuthChecking()) {
    _authSubscription = _authRepository.watchUser().listen(
      _onUserChanged,
      onError: (Object error, StackTrace stackTrace) {
        log.e('Auth state stream failed', error: error, stackTrace: stackTrace);
        if (state is AuthChecking) emit(const AuthUnauthenticated());
      },
    );
  }

  void _onUserChanged(AuthUser? user) {
    if (user == null) {
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(user: user));
    }
  }

  Future<void> signOut() => _authRepository.signOut();

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    await super.close();
  }
}
