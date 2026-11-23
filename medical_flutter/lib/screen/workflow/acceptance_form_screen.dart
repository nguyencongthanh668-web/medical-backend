import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_device_tracking/features/workflow/workflow_api.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';
import 'package:medical_device_tracking/widget/button/custom_filled_button.dart';
import 'package:medical_device_tracking/widget/snack_bar/custom_snackbar.dart';

/// Cán bộ Phòng Vật tư cập nhật kết quả nghiệm thu và chi phí (FR-06, UC-06).
/// type = 'repair' (sau sửa chữa) hoặc 'maintenance' (sau bảo dưỡng định kỳ).
class AcceptanceFormScreen extends StatefulWidget {
  const AcceptanceFormScreen({super.key, required this.deviceId, required this.deviceTitle, required this.type});

  final int deviceId;
  final String deviceTitle;
  final String type;

  @override
  State<AcceptanceFormScreen> createState() => _AcceptanceFormScreenState();
}

class _AcceptanceFormScreenState extends State<AcceptanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _costController = TextEditingController(text: '0');
  final _performedByController = TextEditingController();
  final _documentController = TextEditingController();
  final _noteController = TextEditingController();
  String _result = 'pass';
  DateTime _completedAt = DateTime.now();
  // Ngày bảo dưỡng tiếp theo (tùy chọn). Bỏ trống: máy chủ tính theo chu kỳ của thiết bị.
  DateTime? _nextMaintenance;
  bool _saving = false;

  bool get _isRepair => widget.type == 'repair';

  @override
  void dispose() {
    _costController.dispose();
    _performedByController.dispose();
    _documentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _completedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _completedAt = picked);
  }

  Future<void> _pickNextDate() async {
    final first = _completedAt.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextMaintenance ?? DateTime(_completedAt.year, _completedAt.month + 6, _completedAt.day),
      firstDate: first,
      lastDate: DateTime(_completedAt.year + 10),
    );
    if (picked != null) setState(() => _nextMaintenance = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final response = await WorkflowApi.accept(
        equipmentId: widget.deviceId,
        type: widget.type,
        result: _result,
        cost: double.parse(_costController.text.trim().replaceAll('.', '').replaceAll(',', '')),
        completedAt: DateFormat('yyyy-MM-dd').format(_completedAt),
        performedBy: _performedByController.text.trim(),
        documentUrl: _documentController.text.trim(),
        note: _noteController.text.trim(),
        nextMaintenance: (!_isRepair && _nextMaintenance != null)
            ? DateFormat('yyyy-MM-dd').format(_nextMaintenance!)
            : null,
      );
      if (!mounted) return;
      showCustomSnackBar(context, message: response['message']?.toString() ?? 'Đã lưu kết quả nghiệm thu');
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
      appBar: AppBar(
        title: Text(_isRepair ? 'Nghiệm thu sửa chữa' : 'Kết quả bảo dưỡng'),
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(widget.deviceTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'pass', label: Text('Đạt'), icon: Icon(Icons.check_circle_outline)),
                ButtonSegment(value: 'fail', label: Text('Không đạt'), icon: Icon(Icons.cancel_outlined)),
              ],
              selected: {_result},
              onSelectionChanged: (s) => setState(() => _result = s.first),
            ),
            if (_result == 'fail')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Nghiệm thu không đạt: thiết bị giữ trạng thái đang sửa chữa.', style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ngày hoàn thành'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_completedAt)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            if (!_isRepair && _result == 'pass')
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ngày bảo dưỡng tiếp theo'),
                subtitle: Text(_nextMaintenance == null
                    ? 'Để trống: tính theo chu kỳ của thiết bị'
                    : DateFormat('dd/MM/yyyy').format(_nextMaintenance!)),
                trailing: const Icon(Icons.event_repeat),
                onTap: _pickNextDate,
              ),
            TextFormField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Chi phí (đồng)', border: OutlineInputBorder()),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim().replaceAll('.', '').replaceAll(',', ''));
                return (n == null || n < 0) ? 'Chi phí phải là số không âm' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _performedByController,
              decoration: const InputDecoration(labelText: 'Đơn vị/người thực hiện', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _documentController,
              decoration: const InputDecoration(labelText: 'Đường dẫn biên bản (nếu có)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Ghi chú', border: OutlineInputBorder()),
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
