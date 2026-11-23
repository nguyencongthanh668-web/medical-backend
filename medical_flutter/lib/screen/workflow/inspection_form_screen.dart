import 'package:flutter/material.dart';
import 'package:medical_device_tracking/features/workflow/workflow_api.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';
import 'package:medical_device_tracking/widget/button/custom_filled_button.dart';
import 'package:medical_device_tracking/widget/snack_bar/custom_snackbar.dart';

/// Kỹ thuật viên ghi kết quả kiểm tra sơ bộ và hướng xử lý (FR-03, UC-03).
/// Trả về true khi lưu thành công để màn hình chi tiết tải lại dữ liệu.
class InspectionFormScreen extends StatefulWidget {
  const InspectionFormScreen({super.key, required this.deviceId, required this.deviceTitle});

  final int deviceId;
  final String deviceTitle;

  @override
  State<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _causeController = TextEditingController();
  final _noteController = TextEditingController();
  String _decision = 'in_house';
  bool _saving = false;

  static const _decisions = {
    'self_fix': 'Khoa tự khắc phục theo hướng dẫn',
    'in_house': 'Sửa chữa nội bộ',
    'outsourced': 'Thuê đơn vị bên ngoài (cần trình duyệt)',
  };

  @override
  void dispose() {
    _causeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await WorkflowApi.createInspection(
        equipmentId: widget.deviceId,
        cause: _causeController.text.trim(),
        decision: _decision,
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      showCustomSnackBar(context, message: 'Đã lưu kết quả kiểm tra');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showCustomSnackBar(context, message: e.message, isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả kiểm tra sơ bộ'), backgroundColor: AppColors.mainColor, foregroundColor: Colors.white),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(widget.deviceTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _causeController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Nguyên nhân hỏng *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập nguyên nhân' : null,
            ),
            const SizedBox(height: 16),
            const Text('Hướng xử lý *', style: TextStyle(fontWeight: FontWeight.w600)),
            ..._decisions.entries.map((e) => RadioListTile<String>(
                  value: e.key,
                  groupValue: _decision,
                  title: Text(e.value),
                  onChanged: (v) => setState(() => _decision = v ?? _decision),
                )),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Ghi chú (vật tư cần dùng, ...)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            _saving
                ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                : CustomFilledButton(onPressed: _submit, title: 'Lưu kết quả'),
          ],
        ),
      ),
    );
  }
}
