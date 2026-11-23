import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/detail_device/detail_device_cubit.dart';
import 'package:medical_device_tracking/cubit/detail_device/detail_device_state.dart';
import 'package:medical_device_tracking/cubit/history/history_cubit.dart';
import 'package:medical_device_tracking/cubit/report_device/report_device_cubit.dart';
import 'package:medical_device_tracking/cubit/report_device/report_device_state.dart';
import 'package:medical_device_tracking/features/user_info_storage/user_info_storage.dart';
import 'package:medical_device_tracking/screen/workflow/acceptance_form_screen.dart';
import 'package:medical_device_tracking/screen/workflow/inspection_form_screen.dart';
import 'package:medical_device_tracking/utils/user_role.dart';
import 'package:medical_device_tracking/widget/button/custom_filled_button.dart';
import 'package:medical_device_tracking/widget/snack_bar/custom_snackbar.dart';

/// Nút thao tác ở cuối màn hình chi tiết, hiện theo vai trò (Bảng 2.4) và trạng thái thiết bị.
class DetailDeviceBottomNav extends StatelessWidget {
  const DetailDeviceBottomNav({super.key,
    required this.deviceId,
  });

  final int deviceId;

  bool _hasOpenIncident(String? status) => status == 'was_broken' || status == 'corrected';

  void _refresh(BuildContext context) {
    context.read<DetailDeviceCubit>().getDetailDevice(id: deviceId);
    context.read<HistoryCubit>().load(deviceId);
  }

  Future<void> _openForm(BuildContext context, Widget page) async {
    final changed = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => page));
    if (changed == true && context.mounted) _refresh(context);
  }

  Future<void> _showReportDialog(BuildContext context) async {
    // Nếu lần gửi trước bị mất mạng, điền lại nội dung cũ; gửi lại dùng cùng request_id (NFR-03).
    final symptomController = TextEditingController(
      text: context.read<ReportDeviceCubit>().pendingSymptomFor(deviceId) ?? '',
    );
    String level = 'Cần sửa';
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Báo hỏng thiết bị'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: symptomController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Hiện tượng hỏng hóc',
                  hintText: 'Ví dụ: máy báo lỗi áp lực, không bơm khí',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: level,
                decoration: const InputDecoration(labelText: 'Mức độ'),
                items: const ['Cần sửa', 'Khẩn cấp']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => level = v ?? level),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (symptomController.text.trim().isEmpty) return;
                Navigator.pop(dialogContext, {'symptom': symptomController.text.trim(), 'level': level});
              },
              child: const Text('Gửi báo hỏng'),
            ),
          ],
        ),
      ),
    );
    if (result != null && context.mounted) {
      context.read<ReportDeviceCubit>().reportDevice(
            deviceId: deviceId,
            symptom: result['symptom']!,
            criticalLevel: result['level']!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = UserInfoStorage.getRole();

    return BlocListener<ReportDeviceCubit, ReportDeviceState>(
      listener: (context, state) {
        if (state.status == ReportStatus.success) {
          showCustomSnackBar(context, message: state.message ?? 'Báo hỏng thành công');
          _refresh(context);
        }
        if (state.status == ReportStatus.failure) {
          showCustomSnackBar(context, message: state.message ?? 'Báo hỏng thất bại', isError: true);
        }
      },
      child: BlocBuilder<DetailDeviceCubit, DetailDeviceState>(
        builder: (context, state) {
          final status = state.deviceInfo?.status;
          final title = state.deviceInfo?.title ?? '';
          final buttons = <Widget>[];

          if (role == UserRole.department) {
            buttons.add(_hasOpenIncident(status)
                ? const _InfoBar(text: 'Thiết bị đã được báo hỏng, đang chờ xử lý')
                : CustomFilledButton(onPressed: () => _showReportDialog(context), title: 'Báo hỏng'));
          }
          if (role == UserRole.technician && _hasOpenIncident(status)) {
            buttons.add(CustomFilledButton(
              onPressed: () => _openForm(context, InspectionFormScreen(deviceId: deviceId, deviceTitle: title)),
              title: status == 'corrected' ? 'Cập nhật kết quả kiểm tra' : 'Ghi kết quả kiểm tra',
            ));
          }
          if (role == UserRole.manager) {
            if (_hasOpenIncident(status)) {
              buttons.add(CustomFilledButton(
                onPressed: () => _openForm(context,
                    AcceptanceFormScreen(deviceId: deviceId, deviceTitle: title, type: 'repair')),
                title: 'Nghiệm thu sửa chữa',
              ));
            } else {
              buttons.add(CustomFilledButton(
                onPressed: () => _openForm(context,
                    AcceptanceFormScreen(deviceId: deviceId, deviceTitle: title, type: 'maintenance')),
                title: 'Ghi kết quả bảo dưỡng',
              ));
            }
          }
          if (buttons.isEmpty) return const SizedBox.shrink();

          return Container(
            color: Colors.white,
            child: Column(mainAxisSize: MainAxisSize.min, children: buttons),
          );
        },
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  const _InfoBar({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
