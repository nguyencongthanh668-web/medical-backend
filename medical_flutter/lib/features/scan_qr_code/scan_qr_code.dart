import 'package:medical_device_tracking/features/workflow/workflow_api.dart';

/// Đọc nội dung mã QR dán trên thiết bị.
/// Mã mới có dạng "medical-equipment:<id>"; mã cũ là URL kết thúc bằng mã thiết bị.
class ScanQrCode {
  static int? parseEquipmentId(String raw) {
    final match = RegExp(r'(\d+)\s*$').firstMatch(raw.trim());
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  /// Trả về {id, department_id} của thiết bị; lỗi quyền hoặc không tìm thấy ném ApiException.
  static Future<Map<String, int>> resolve(String raw) async {
    final id = parseEquipmentId(raw);
    if (id == null) throw ApiException('Mã QR không phải mã thiết bị của hệ thống');
    final data = await WorkflowApi.getEquipment(id);
    return {
      'id': (data['id'] as num?)?.toInt() ?? id,
      'department_id': (data['department_id'] as num?)?.toInt() ?? 0,
    };
  }
}
