import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/profile/profile_state.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/features/user_info_storage/user_info_storage.dart';
import 'package:medical_device_tracking/model/user_data.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState(status: ProfileStatus.initial));

  Future<void> getProfile() async {
    emit(state.copyWith(
      status: ProfileStatus.loading
    ));

    final id = await UserInfoStorage.getUserId();
    final getProfileEndPoint = '${EndPoints.getListStaff}/$id';
    final dio = getIt<DioConfig>().dio;

    try {
      final response = await dio.get(getProfileEndPoint);

      if (response.statusCode == 200) {
        final data = UserInfoResponse.fromJson(response.data);

        emit(state.copyWith(
          status: ProfileStatus.success,
          userInfo: data.data,
        ));
      }

      else {
        emit(state.copyWith(
          status: ProfileStatus.failure
        ));
      }
    }

    on DioException catch(e,s) {
      emit(state.copyWith(
          status: ProfileStatus.failure
      ));

      log(e.toString());
      log(s.toString());
    }

    catch(e,s) {
      emit(state.copyWith(
          status: ProfileStatus.failure
      ));

      log(e.toString());
      log(s.toString());
    }
  }
}