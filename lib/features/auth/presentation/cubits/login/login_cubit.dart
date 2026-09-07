import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_exception_code.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginInitial());

  Future<void> logIn() async {
    if (state is LoginSubmitting) return;
    emit(const LoginSubmitting());
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!isClosed) emit(const LoginSuccess());
  }
}
