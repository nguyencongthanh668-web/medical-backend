import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/all_device/all_device_state.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/model/list_device.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class AllDeviceCubit extends Cubit<AllDeviceState> {
  AllDeviceCubit() : super(AllDeviceState(
      status: AllDeviceLoadingStatus.initial,
  ));

  void setQueryStatus({required DeviceStatus queryStatus}) {
    emit(state.copyWith(
      pageIndex: 1,
      queryStatus: queryStatus
    ));

    getListDevice(
      page: state.pageIndex,
      status: state.queryStatus.name
    );
  }

  void nextPage() {
    emit(state.copyWith(
        pageIndex: state.pageIndex + 1
    ));

    getListDevice(
      page: state.pageIndex,
      status: state.queryStatus.name,
    );
  }

  void previousPage() {
    if(state.pageIndex > 1) {
      emit(state.copyWith(
        pageIndex: state.pageIndex - 1
      ));

      getListDevice(
        page: state.pageIndex,
        status: state.queryStatus.name,
      );
    }
  }

  Future<void> getListDevice({required int page, String? status}) async {
    emit(state.copyWith(
      status: AllDeviceLoadingStatus.loading,
      pageIndex: page
    ));

    final dio = getIt<DioConfig>().dio;
    final getListDeviceEndPoint = EndPoints.getListDevice;
    final params = {
      'page': page,
      if (status != null && status != DeviceStatus.all.name) 'status': status,
    };

    try {
      final response = await dio.get(
        getListDeviceEndPoint,
        queryParameters: params
      );

      if (response.statusCode == 200) {
        final data = ListDeviceResponse.fromJson(response.data);

        emit(state.copyWith(
          status: AllDeviceLoadingStatus.success,
          message: 'Tải danh sách thiết bị thành công',
          listDevice: data.data.data
        ));

        log('Tải danh sách thiết bị thành công');
      }

      else {}
    }

    on DioException catch(e,s) {
      emit(state.copyWith(
        status: AllDeviceLoadingStatus.failure,
        message: 'Tải danh sách thiết bị không thành công',
      ));

      log(e.toString());
      log(s.toString());
      log('Tải danh sách thiết bị không thành công');
    }

    catch(e,s) {
      emit(state.copyWith(
        status: AllDeviceLoadingStatus.failure,
        message: 'Tải danh sách thiết bị không thành công',
      ));

      log(e.toString());
      log(s.toString());
      log('Tải danh sách thiết bị không thành công');
    }
  }

}