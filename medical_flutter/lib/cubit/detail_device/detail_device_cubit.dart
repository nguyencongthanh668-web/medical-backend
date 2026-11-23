import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/detail_device/detail_device_state.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/model/device.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class DetailDeviceCubit extends Cubit<DetailDeviceState> {
  DetailDeviceCubit() : super(DetailDeviceState(status: DetailDeviceLoadStatus.initial));

  Future<void> getDetailDevice({required int id}) async {
    emit(state.copyWith(
      status: DetailDeviceLoadStatus.loading
    ));

    final dio = getIt<DioConfig>().dio;
    final getDetailDeviceEndPoint = '${EndPoints.getCountDevice}/$id';

    try {
      final response = await dio.get(getDetailDeviceEndPoint);

      if (response.statusCode == 200) {
        final data = DeviceDetailModel.fromJson(response.data['data']);

        emit(state.copyWith(
          status: DetailDeviceLoadStatus.success,
          deviceInfo: data,
          message: 'Tải thông tin thiết bị thành công'
        ));

        log('Tải thông tin thiết bị thành công');
      }

      else {
        emit(state.copyWith(
          status: DetailDeviceLoadStatus.failure,
          message: 'Tải thông tin thiết bị thất bại'
        ));

        log('Tải thông tin thiết bị thất bại');
      }
    }

    on DioException catch(e,s) {
      emit(state.copyWith(
          status: DetailDeviceLoadStatus.failure,
          message: 'Tải thông tin thiết bị thất bại'
      ));

      log(e.toString());
      log(s.toString());
    }

    catch(e,s) {
      emit(state.copyWith(
          status: DetailDeviceLoadStatus.failure,
          message: 'Tải thông tin thiết bị thất bại'
      ));

      log(e.toString());
      log(s.toString());
    }
  }
}