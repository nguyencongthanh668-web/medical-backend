import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/logout/logout_state.dart';
import 'package:medical_device_tracking/features/auth/logout.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutState(status: LogoutStatus.initial));

  Future<void> logout() async {
    // Cubit dùng chung toàn ứng dụng: chuyển về loading trước để lần đăng xuất sau
    // vẫn phát trạng thái success mới và màn hình nhận được sự kiện.
    emit(state.copyWith(status: LogoutStatus.loading));
    final String message = await Logout.logout();

    if (message == 'Logout Success') {
      emit(state.copyWith(
        status: LogoutStatus.success
      ));
    }

    else {
      emit(state.copyWith(
        status: LogoutStatus.failure
      ));
    }
  }
}