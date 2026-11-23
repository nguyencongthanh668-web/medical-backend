import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/model/department.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class GetDetailDepartment {
  static Future<DepartmentModel?> getDetailDepartment({required int id}) async {
    final dio = getIt<DioConfig>().dio;
    final getDetailDepartmentEndPoint = '${EndPoints.getListDepartment}/$id';

    try {
      final response = await dio.get(getDetailDepartmentEndPoint);

      if (response.statusCode == 200) {
        final data = DepartmentResponse.fromJson(response.data);

        log('Lấy chi tiết phòng ban thành công');

        return data.data;
      }

      else {
        log('Lấy chi tiết phòng ban thất bại');

        return null;
      }
    }

    on DioException catch(e,s) {
      log(e.toString());
      log(s.toString());

      return null;
    }

    catch(e,s) {
      log(e.toString());
      log(s.toString());

      return null;
    }
  }
}