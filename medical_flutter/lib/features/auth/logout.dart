import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

class Logout {
  /// Gọi API đăng xuất rồi xóa token, vai trò và thông tin người dùng đã lưu.
  /// Dữ liệu cục bộ luôn được xóa kể cả khi mất mạng, để tài khoản sau không dùng nhầm quyền.
  static Future<String> logout() async {
    final dio = getIt<DioConfig>().dio;
    try {
      await dio.post(EndPoints.logoutEndPoint);
    } catch (_) {
      // JWT không lưu trạng thái ở máy chủ; bỏ qua lỗi mạng khi đăng xuất.
    }
    await Hive.box('authBox').clear();
    return 'Logout Success';
  }
}
