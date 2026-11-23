import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/login/login_state.dart';
import 'package:medical_device_tracking/features/auth/login.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState(status: LoginStatus.initial));

  Future<void> login({required String username,
    required String password,
  }) async {
    emit(state.copyWith(
      status: LoginStatus.loading,
    ));

    final String message = await Auth.login(
      username: username,
      password: password,
    );

    emit(state.copyWith(
      status: handleStatus(message),
      message: handleMessage(message),
    ));
  }
}


LoginStatus handleStatus(String message) {
  switch(message) {
    case 'Success':
      return LoginStatus.success;
    default :
      return LoginStatus.failure;
  }
}

String handleMessage(String message) {
  switch(message) {
    case 'Success':
      return 'Đăng nhập thành công';
    default :
      return 'Đăng nhập thất bại';
  }
}