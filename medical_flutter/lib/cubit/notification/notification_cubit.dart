import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/notification/notification_state.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/model/notification.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationState(status: NotificationStatus.initial));

  Future<void> getNotification() async {
    final String notificationEnPoints = EndPoints.getNotification;
    final dio = getIt<DioConfig>().dio;

    emit(state.copyWith(
      status: NotificationStatus.loading
    ));

    try {
      final response = await dio.get(notificationEnPoints);

      if (response.statusCode == 200) {
        final data = NotificationResponse.fromJson(response.data);

        emit(state.copyWith(
          status: NotificationStatus.success,
          listNotification: data.data
        ));
      }

      else {
        emit(state.copyWith(
          status: NotificationStatus.failure
        ));
      }
    }

    on DioException catch(e,s) {
      emit(state.copyWith(
          status: NotificationStatus.failure
      ));

      log(e.toString());
      log(s.toString());
    }

    catch(e,s) {
      emit(state.copyWith(
          status: NotificationStatus.failure
      ));

      log(e.toString());
      log(s.toString());
      print('========= LỖI DỮ LIỆU Ở ĐÂY =========');
      print(e.toString());
      print('=====================================');
    }
  }
}