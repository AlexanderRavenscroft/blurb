import 'dart:async';

import 'package:blurb/features/auth/domain/auth_exception.dart';
import 'package:blurb/features/auth/domain/auth_repository.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'social_auth_state.dart';

class SocialAuthCubit extends Cubit<SocialAuthState> {
  final AuthRepository _authRepository;
  bool _receivedOAuthRedirect = false;

  SocialAuthCubit({required this._authRepository})
    : super(const SocialAuthInitial());

  bool get _isInProgress =>
      state is SocialAuthSubmitting || state is SocialAuthAwaitingOAuthRedirect;

  Future<void> signInWithGoogle() async {
    if (_isInProgress) return;

    emit(const SocialAuthSubmitting());

    try {
      await _authRepository.signInWithGoogle();
    } on AuthException catch (exception) {
      emit(SocialAuthFailure(exception.code));
    } catch (error, stackTrace) {
      log.e(
        'Unexpected Google sign-in failure',
        error: error,
        stackTrace: stackTrace,
      );
      emit(const SocialAuthFailure(AuthExceptionCode.unknown));
    }
  }

  Future<void> signInWithFacebook() async {
    return _signInWithOAuth(
      providerName: 'Facebook',
      signIn: _authRepository.signInWithFacebook,
    );
  }

  Future<void> signInWithDiscord() async {
    return _signInWithOAuth(
      providerName: 'Discord',
      signIn: _authRepository.signInWithDiscord,
    );
  }

  Future<void> _signInWithOAuth({
    required String providerName,
    required Future<void> Function() signIn,
  }) async {
    if (_isInProgress) return;

    _receivedOAuthRedirect = false;
    emit(const SocialAuthSubmitting());

    try {
      await signIn();

      if (state is SocialAuthSubmitting) {
        emit(const SocialAuthAwaitingOAuthRedirect());
      }
    } on AuthException catch (exception) {
      emit(SocialAuthFailure(exception.code));
    } catch (error, stackTrace) {
      log.e(
        'Unexpected $providerName sign-in failure',
        error: error,
        stackTrace: stackTrace,
      );
      emit(const SocialAuthFailure(AuthExceptionCode.unknown));
    }
  }

  void oauthRedirectReceived() {
    if (!_isInProgress) return;

    _receivedOAuthRedirect = true;
  }

  void oauthRedirectFailed() {
    if (!_isInProgress) return;

    _receivedOAuthRedirect = true;
    emit(const SocialAuthFailure(AuthExceptionCode.unknown));
  }

  void oauthFlowReturnedWithoutRedirect() {
    if (state is! SocialAuthAwaitingOAuthRedirect || _receivedOAuthRedirect) {
      return;
    }

    emit(const SocialAuthFailure(AuthExceptionCode.unknown));
  }
}
