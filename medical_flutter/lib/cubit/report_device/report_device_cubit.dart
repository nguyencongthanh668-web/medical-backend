import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/report_device/report_device_state.dart';
import 'package:medical_device_tracking/features/workflow/workflow_api.dart';

/// Báo hỏng (FR-02, UC-02). Mỗi lần báo có một request_id; nếu mất mạng và người dùng
/// bấm gửi lại cho cùng thiết bị, ứng dụng dùng lại mã đó nên máy chủ không tạo bản ghi trùng.
class ReportDeviceCubit extends Cubit<ReportDeviceState> {
  ReportDeviceCubit() : super(ReportDeviceState(status: ReportStatus.initial));

  String? _pendingRequestId;
  int? _pendingDeviceId;
  String? _pendingSymptom;

  /// Hiện tượng đã nhập của lần gửi bị lỗi mạng, để điền sẵn khi người dùng gửi lại.
  String? pendingSymptomFor(int deviceId) => _pendingDeviceId == deviceId && _pendingRequestId != null ? _pendingSymptom : null;

  Future<void> reportDevice({
    required int deviceId,
    required String symptom,
    String criticalLevel = 'Cần sửa',
  }) async {
    if (_pendingDeviceId != deviceId || _pendingRequestId == null) {
      _pendingDeviceId = deviceId;
      _pendingRequestId = WorkflowApi.newRequestId();
    }
    _pendingSymptom = symptom;

    emit(state.copyWith(status: ReportStatus.loading));

    try {
      await WorkflowApi.reportFailure(
        equipmentId: deviceId,
        symptom: symptom,
        criticalLevel: criticalLevel,
        requestId: _pendingRequestId!,
      );
      _pendingRequestId = null;
      emit(state.copyWith(
        status: ReportStatus.success,
        message: 'Đã báo hỏng, kỹ thuật viên sẽ nhận được thông báo',
      ));
      log('Báo hỏng thành công');
    } catch (e, s) {
      final error = e is ApiException ? e : WorkflowApi.toApiException(e);
      // Lỗi có phản hồi từ máy chủ (sai quyền, đã báo trước đó...) thì bỏ mã cũ; lỗi mạng thì giữ để gửi lại.
      if (error.statusCode != null) _pendingRequestId = null;
      emit(state.copyWith(status: ReportStatus.failure, message: error.message));
      log(e.toString());
      log(s.toString());
    }
  }
}
