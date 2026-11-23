import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/splash/splash_state.dart';
import 'package:medical_device_tracking/features/remember_me/remember_me_state_storage.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashState(status: SplashStatus.initial));

  Future<bool> checkRememberMe() async {
    final isRememberMe = await RememberMeStateStorage.getRememberMeState();

    return isRememberMe ?? false;
  }

  Future<void> initialApp() async {
    emit(state.copyWith(
      status: SplashStatus.loading,
      message: 'Đang kiểm tra đăng nhập'
    ));

    log('Đang kiểm tra đăng nhập');

    final isRememberMe = await checkRememberMe();

    emit(state.copyWith(
      status: SplashStatus.success,
      isRememberMe: isRememberMe,
      message: (isRememberMe) ? 'Đang đăng nhập' : 'Chuyển hướng sang trang đăng nhập'
    ));

    log((isRememberMe) ? 'Đang đăng nhập' : 'Chuyển hướng sang trang đăng nhập');
  }
}