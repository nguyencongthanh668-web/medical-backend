import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/all_department/all_department_state.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/model/department.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class AllDepartmentCubit extends Cubit<AllDepartmentState> {
  AllDepartmentCubit() : super(AllDepartmentState(status: AllDepartmentStatus.initial));

  Future<void> getAllDepartment() async {
    final getAllDepartmentEndPoint = EndPoints.getListDepartment;
    final dio = getIt<DioConfig>().dio;

    emit(state.copyWith(
      status: AllDepartmentStatus.loading
    ));

    try {
      final response = await dio.get(getAllDepartmentEndPoint);

      if (response.statusCode == 200) {
        final data = DepartmentResponseX.fromJson(response.data);

        emit(state.copyWith(
          status: AllDepartmentStatus.success,
          listDepartment: data.data,
          message: 'Tải danh sách phòng ban thành công'
        ));

        log('Tải danh sách phòng ban thành công');
      }

      else {
        emit(state.copyWith(
          status: AllDepartmentStatus.failure,
          message: 'Tải danh sách phòng ban thất bại'
        ));

        log('Tải danh sách phòng ban thất bại');
      }
    }

    on DioException catch(e,s) {
      emit(state.copyWith(
        status: AllDepartmentStatus.failure,
        message: 'Tải danh sách phòng ban thất bại',
      ));

      log(e.toString());
      log(s.toString());
    }

    catch(e,s) {
      emit(state.copyWith(
        status: AllDepartmentStatus.failure,
        message: 'Tải danh sách phòng ban thất bại',
      ));

      log(e.toString());
      log(s.toString());
    }
  }
}