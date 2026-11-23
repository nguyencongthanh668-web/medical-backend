import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/all_staff/all_staff_state.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/model/user_data.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class AllStaffCubit extends Cubit<AllStaffState> {
  AllStaffCubit() : super(AllStaffState(status: AllStaffStatus.initial));

  Future<void> getListStaff() async {
    final getListStaffEndPoint = EndPoints.getListStaff;
    final dio = getIt<DioConfig>().dio;

    emit(state.copyWith(
      status: AllStaffStatus.loading
    ));

    try {
      final response = await dio.get(getListStaffEndPoint);

      if (response.statusCode == 200) {
        final data = UserResponse.fromJson(response.data);

        emit(state.copyWith(
          status: AllStaffStatus.success,
          listUser: data.data,
        ));
      }

      else {
        emit(state.copyWith(
          status: AllStaffStatus.failure,
        ));
      }
    }

    on DioException catch(e,s) {
      emit(state.copyWith(
        status: AllStaffStatus.failure,
      ));

      log(e.toString());
      log(s.toString());
    }

    catch(e, s) {
    emit(state.copyWith(
       status: AllStaffStatus.failure,
    ));
    
    // Thêm dòng print thần thánh này vào đây
    print('========= LỖI DỮ LIỆU Ở ĐÂY =========');
    print(e.toString());
    print('=====================================');
      }
  }
}