import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthChecking()) {
    _watch();
  }

  int _watchVersion = 0;

  Future<void> _watch() async {
    final version = ++_watchVersion;
    emit(const AuthChecking());
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!isClosed && version == _watchVersion) {
      emit(const AuthAuthenticated());
    }
  }

  void authenticate() {
    _watchVersion++;
    emit(const AuthAuthenticated());
  }

  void signOut() {
    _watchVersion++;
    emit(const AuthUnauthenticated());
  }
}
