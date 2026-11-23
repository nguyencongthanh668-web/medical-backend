import 'package:dio/dio.dart';
import 'package:medical_device_tracking/features/get_base_url/get_base_url.dart';
import 'package:medical_device_tracking/features/token_storage/token_storage.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class DioConfig {
  late Dio dio;

  DioConfig() {
    dio = Dio(
      BaseOptions(
        baseUrl: BaseUrl.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
      )
    );

    dio.interceptors.add(
      LogInterceptor(
        requestUrl: true,
        requestHeader: true,
        requestBody: true,
        request: true,
        responseUrl: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      )
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options,handler) async {
          final token = await TokenStorage.getToken();
          options.headers['Authorization'] = 'Bearer $token';

          return handler.next(options);
        }
      )
    );
  }
}