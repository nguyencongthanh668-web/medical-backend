import 'dart:math';

import 'package:dio/dio.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/model/equipment_history.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';
import 'package:medical_device_tracking/network/url/app_url.dart';

/// Lỗi trả về từ API, giữ nguyên thông báo tiếng Việt của máy chủ để hiển thị cho người dùng.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Tầng truy cập dữ liệu: mọi lời gọi API nghiệp vụ (FR-01 đến FR-06) đi qua lớp này;
/// cubit không dùng Dio trực tiếp.
class WorkflowApi {
  static Dio get _dio => getIt<DioConfig>().dio;

  /// Phân biệt lỗi dữ liệu/quyền (có thông báo của máy chủ) với lỗi mạng (NFR-03, NFR-04).
  static ApiException toApiException(Object error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null) {
        final data = response.data;
        final message = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : 'Yêu cầu thất bại (mã ${response.statusCode})';
        return ApiException(message, response.statusCode);
      }
      return ApiException('Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.');
    }
    return ApiException(error.toString());
  }

  /// Mã yêu cầu duy nhất để gửi lại khi mất mạng mà máy chủ không tạo bản ghi trùng.
  static String newRequestId() {
    final random = Random.secure();
    final suffix = List.generate(8, (_) => random.nextInt(36).toRadixString(36)).join();
    return '${DateTime.now().millisecondsSinceEpoch}-$suffix';
  }

  static Future<Map<String, dynamic>> _send(Future<Response> Function() call) async {
    try {
      final response = await call();
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw toApiException(e);
    }
  }

  /// FR-02: báo hỏng; requestId giữ nguyên khi gửi lại sau lỗi mạng (NFR-03).
  static Future<Map<String, dynamic>> reportFailure({
    required int equipmentId,
    required String symptom,
    required String criticalLevel,
    required String requestId,
  }) {
    return _send(() => _dio.post(EndPoints.reportFailure(equipmentId), data: {
          'symptom': symptom,
          'critical_level': criticalLevel,
          'request_id': requestId,
        }));
  }

  static Future<EquipmentHistory> getHistory(int equipmentId) async {
    final data = await _send(() => _dio.get(EndPoints.history(equipmentId)));
    return EquipmentHistory.fromJson(Map<String, dynamic>.from(data['data'] as Map));
  }

  static Future<Map<String, dynamic>> createInspection({
    required int equipmentId,
    required String cause,
    required String decision,
    String? note,
  }) {
    return _send(() => _dio.post(EndPoints.inspectionResults(equipmentId), data: {
          'cause': cause,
          'decision': decision,
          if (note != null && note.isNotEmpty) 'note': note,
        }));
  }

  static Future<Map<String, dynamic>> accept({
    required int equipmentId,
    required String type,
    required String result,
    required double cost,
    required String completedAt,
    String? performedBy,
    String? documentUrl,
    String? note,
    String? nextMaintenance,
  }) {
    return _send(() => _dio.put(EndPoints.acceptance(equipmentId), data: {
          'type': type,
          'result': result,
          'cost': cost,
          'completed_at': completedAt,
          if (performedBy != null && performedBy.isNotEmpty) 'performed_by': performedBy,
          if (documentUrl != null && documentUrl.isNotEmpty) 'document_url': documentUrl,
          if (note != null && note.isNotEmpty) 'note': note,
          if (nextMaintenance != null) 'next_maintenance': nextMaintenance,
        }));
  }

  static Future<List<MaintenanceAlert>> getAlerts({int days = 30}) async {
    final data = await _send(() => _dio.get(EndPoints.maintenanceAlerts, queryParameters: {'days': days}));
    return (data['data'] as List<dynamic>? ?? [])
        .map((e) => MaintenanceAlert.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<Map<String, dynamic>> scanAlerts() {
    return _send(() => _dio.post(EndPoints.scanMaintenanceAlerts));
  }

  static Future<Map<String, dynamic>> createEquipment(Map<String, dynamic> body) {
    return _send(() => _dio.post(EndPoints.createEquipment, data: body));
  }

  /// Lấy mã và khoa của thiết bị (dùng sau khi quét QR để mở màn hình chi tiết).
  static Future<Map<String, dynamic>> getEquipment(int equipmentId) async {
    final data = await _send(() => _dio.get(EndPoints.equipmentDetail(equipmentId)));
    return Map<String, dynamic>.from(data['data'] as Map);
  }

  static Future<List<Map<String, dynamic>>> getDepartments() async {
    final data = await _send(() => _dio.get(EndPoints.getListDepartment));
    return (data['data'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
