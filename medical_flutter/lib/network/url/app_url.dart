import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class BaseUrl {
  // Bản web do backend phục vụ (http://localhost:3000) gọi API cùng địa chỉ;
  // khi chạy `flutter run -d web-server` (cổng khác) vẫn trỏ về localhost:3000.
  static String baseUrl = kIsWeb
      ? (Uri.base.port == 3000 ? '${Uri.base.origin}/' : 'http://localhost:3000/')
      : 'http://10.0.2.2:3000/';
}

class EndPoints {
  static const String loginEndPoint = 'api/login';
  static const String getCountDevice = 'api/v1/equipments';
  static const String getListDevice = 'api/v2/equipments';
  static const String getListDepartment = 'api/v1/departments';
  static const String getNotification = 'api/v1/notification';
  static const String getListStaff = 'api/v1/users';
  static const String logoutEndPoint = 'api/v1/logout';

  // Các API nghiệp vụ theo Bảng 3.3, 3.4 của báo cáo.
  static const String createEquipment = 'api/v1/equipments'; // FR-01 (POST)
  static String equipmentDetail(int id) => 'api/v1/equipments/$id';
  static String reportFailure(int id) => 'api/v1/equipments/$id/repair'; // FR-02
  static String inspectionResults(int id) => 'api/v1/equipments/$id/inspection-results'; // FR-03
  static const String maintenanceAlerts = 'api/v1/maintenance-alerts'; // FR-04
  static const String scanMaintenanceAlerts = 'api/v1/maintenance-alerts/scan';
  static String history(int id) => 'api/v1/equipments/$id/history'; // FR-05
  static String acceptance(int id) => 'api/v1/equipments/$id/acceptance'; // FR-06
}
