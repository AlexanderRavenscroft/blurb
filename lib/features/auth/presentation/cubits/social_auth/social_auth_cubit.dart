import 'package:blurb/features/auth/domain/exceptions/auth_exception.dart';
import 'package:blurb/features/auth/domain/repositories/auth_repository.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'social_auth_state.dart';

class SocialAuthCubit extends Cubit<SocialAuthState> {
  final AuthRepository _authRepository;

  SocialAuthCubit({required this._authRepository})
    : super(const SocialAuthInitial());

  Future<void> signInWithGoogle() async {
    if (state is SocialAuthSubmitting) return;

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
}
