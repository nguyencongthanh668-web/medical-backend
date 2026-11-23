import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:medical_device_tracking/features/get_base_url/get_base_url.dart';
import 'package:medical_device_tracking/features/token_storage/token_storage.dart';
import 'package:medical_device_tracking/features/user_info_storage/user_info_storage.dart';
import 'package:medical_device_tracking/model/auth_response.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class Auth {
  static Future<String> login({required String username,
    required String password,
  }) async {
    final loginUrl = '${BaseUrl.baseUrl}${EndPoints.loginEndPoint}';
    final dio = Dio();

    dio.interceptors.add(
      LogInterceptor(
        requestUrl: true,
        request: true,
        requestHeader: true,
        requestBody: true,
        responseUrl: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      )
    );

    try {
      final response = await dio.post(
        loginUrl,
        data: {
          "email" : username,
          "password" : password,
        }
      );

      if (response.statusCode == 200) {
        final data = AuthResponse.fromJson(response.data);
        final String token = data.accessToken;
        log(token);
        await TokenStorage.saveToken(token: data.accessToken);

        await UserInfoStorage.saveUserInfo(
          id: data.data.id,
          displayname: data.data.displayName,
          email: data.data.email,
          phone: data.data.phone,
          birthday: data.data.birthday.toString(),
          gender: data.data.gender.toString(),
          profilePhotoUrl: data.data.profilePhotoUrl,
          role: data.data.role,
          departmentId: data.data.departmentId == 0 ? null : data.data.departmentId,
        );

        return 'Success';
      }

      else {
        return 'Error';
      }

    }

    on DioException catch(e,s) {
      log(e.toString());
      log(s.toString());

      return 'Dio Exception';
    }

    catch(e,s) {
      print('=== LỖI RỒI NÀY ===');
  print(e.toString());
  return 'Error';
    }
  }

}