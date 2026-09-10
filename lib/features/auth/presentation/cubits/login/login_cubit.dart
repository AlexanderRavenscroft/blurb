import 'package:blurb/features/auth/domain/auth_exception.dart';
import 'package:blurb/features/auth/domain/auth_repository.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit({required this._authRepository}) : super(const LoginInitial());

  Future<void> logIn({required String email, required String password}) async {
    if (state is LoginSubmitting) return;

    emit(const LoginSubmitting());

    try {
      await _authRepository.logIn(email: email.trim(), password: password);
    } on AuthException catch (exception) {
      emit(LoginFailure(exception.code));
    } catch (error, stackTrace) {
      log.e('Unexpected login failure', error: error, stackTrace: stackTrace);
      emit(const LoginFailure(AuthExceptionCode.unknown));
    }
  }
}
