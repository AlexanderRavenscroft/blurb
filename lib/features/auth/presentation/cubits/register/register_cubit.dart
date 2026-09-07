import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth_exception_code.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterInitial());

  Future<void> register() async {
    if (state is RegisterSubmitting) return;
    emit(const RegisterSubmitting());
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!isClosed) emit(const RegisterSuccess());
  }
}
