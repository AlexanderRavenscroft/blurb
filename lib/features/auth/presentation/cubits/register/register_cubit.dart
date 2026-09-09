import 'package:blurb/features/auth/domain/exceptions/auth_exception.dart';
import 'package:blurb/features/auth/domain/repositories/auth_repository.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit({required this._authRepository})
    : super(const RegisterInitial());

  Future<void> register({
    required String email,
    required String password,
  }) async {
    if (state is RegisterSubmitting) return;

    emit(const RegisterSubmitting());

    try {
      await _authRepository.register(email: email.trim(), password: password);
    } on AuthException catch (exception) {
      emit(RegisterFailure(exception.code));
    } catch (error, stackTrace) {
      log.e(
        'Unexpected register failure',
        error: error,
        stackTrace: stackTrace,
      );
      emit(const RegisterFailure(AuthExceptionCode.unknown));
    }
  }
}
