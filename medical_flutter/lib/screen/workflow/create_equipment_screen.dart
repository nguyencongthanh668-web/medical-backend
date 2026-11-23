import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:medical_device_tracking/features/workflow/workflow_api.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';
import 'package:medical_device_tracking/widget/button/custom_filled_button.dart';
import 'package:medical_device_tracking/widget/snack_bar/custom_snackbar.dart';

/// Lập hồ sơ thiết bị và sinh mã QR để in dán lên máy (FR-01, UC-01).
class CreateEquipmentScreen extends StatefulWidget {
  const CreateEquipmentScreen({super.key});

  @override
  State<CreateEquipmentScreen> createState() => _CreateEquipmentScreenState();
}

class _CreateEquipmentScreenState extends State<CreateEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _code = TextEditingController();
  final _serial = TextEditingController();
  final _model = TextEditingController();
  final _manufacturer = TextEditingController();
  final _cycle = TextEditingController(text: '6');
  DateTime? _nextMaintenance;
  int? _departmentId;
  List<Map<String, dynamic>> _departments = [];
  bool _saving = false;
  String? _qrContent;
  String? _createdTitle;

  @override
  void initState() {
    super.initState();
    WorkflowApi.getDepartments().then((list) {
      if (mounted) setState(() => _departments = list);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    for (final c in [_title, _code, _serial, _model, _manufacturer, _cycle]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextMaintenance ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _nextMaintenance = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final response = await WorkflowApi.createEquipment({
        'title': _title.text.trim(),
        'code': _code.text.trim(),
        'department_id': _departmentId,
        'serial': _serial.text.trim(),
        'model': _model.text.trim(),
        'manufacturer': _manufacturer.text.trim(),
        'regular_maintenance': int.tryParse(_cycle.text.trim()) ?? 0,
        if (_nextMaintenance != null) 'next_maintenance': DateFormat('yyyy-MM-dd').format(_nextMaintenance!),
      });
      final data = response['data'] as Map;
      if (!mounted) return;
      setState(() {
        _qrContent = data['qr_content']?.toString();
        _createdTitle = _title.text.trim();
      });
      showCustomSnackBar(context, message: 'Đã tạo hồ sơ thiết bị');
    } on ApiException catch (e) {
      if (mounted) showCustomSnackBar(context, message: e.message, isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(labelText: label, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm thiết bị'), backgroundColor: AppColors.mainColor, foregroundColor: Colors.white),
      body: _qrContent != null ? _buildQr() : _buildForm(),
    );
  }

  Widget _buildQr() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_createdTitle ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            QrImageView(data: _qrContent!, size: 220, backgroundColor: Colors.white),
            const SizedBox(height: 8),
            Text(_qrContent!, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            const Text('In mã này và dán lên thiết bị để Khoa/Phòng quét khi báo hỏng.', textAlign: TextAlign.center),
            CustomFilledButton(onPressed: () => Navigator.pop(context, true), title: 'Xong'),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _title,
            decoration: _decoration('Tên thiết bị *'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên thiết bị' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _code,
            decoration: _decoration('Mã thiết bị *'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập mã thiết bị' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _departmentId,
            decoration: _decoration('Khoa/Phòng sử dụng *'),
            items: _departments
                .map((d) => DropdownMenuItem<int>(
                      value: (d['id'] as num).toInt(),
                      child: Text((d['title'] ?? d['name'] ?? 'Khoa ${d['id']}').toString()),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _departmentId = v),
            validator: (v) => v == null ? 'Vui lòng chọn khoa/phòng' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _serial, decoration: _decoration('Số serial')),
          const SizedBox(height: 12),
          TextFormField(controller: _model, decoration: _decoration('Model')),
          const SizedBox(height: 12),
          TextFormField(controller: _manufacturer, decoration: _decoration('Hãng sản xuất')),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cycle,
            keyboardType: TextInputType.number,
            decoration: _decoration('Chu kỳ bảo dưỡng (tháng)'),
            validator: (v) => (int.tryParse((v ?? '').trim()) ?? -1) < 0 ? 'Nhập số tháng (0 nếu không bảo dưỡng định kỳ)' : null,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ngày bảo dưỡng tiếp theo'),
            subtitle: Text(_nextMaintenance != null ? DateFormat('dd/MM/yyyy').format(_nextMaintenance!) : 'Chưa chọn'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          _saving
              ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              : CustomFilledButton(onPressed: _submit, title: 'Lưu và tạo mã QR'),
        ],
      ),
    );
  }
}
