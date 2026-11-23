import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/model/count_device_analytic.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class GetCountActiveDevice {
  static Future<int> getCountActiveDevice() async {
    final dio = getIt<DioConfig>().dio;
    final String getCountActiveDevice = EndPoints.getCountDevice;

    try {
      final response = await dio.get(
        getCountActiveDevice,
        queryParameters: {
          'status' : 'active'
        }
      );

      if (response.statusCode == 200) {
        final data = CountDeviceAnalytic.fromJson(response.data);

        return data.dataLength;
      }

      else {
        return 0;
      }
    }

    on DioException catch(e,s) {
      log(e.toString());
      log(s.toString());

      return 0;
    }

    catch(e,s) {
      log(e.toString());
      log(s.toString());

      return 0;
    }
  }
}