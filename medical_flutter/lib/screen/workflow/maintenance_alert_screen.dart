import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_device_tracking/features/workflow/workflow_api.dart';
import 'package:medical_device_tracking/model/equipment_history.dart';
import 'package:medical_device_tracking/screen/detail_device/detail_device_screen.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';
import 'package:medical_device_tracking/widget/snack_bar/custom_snackbar.dart';

/// Dashboard "Cần lập kế hoạch bảo dưỡng" của cán bộ Phòng Vật tư (FR-04, UC-04).
class MaintenanceAlertScreen extends StatefulWidget {
  const MaintenanceAlertScreen({super.key});

  @override
  State<MaintenanceAlertScreen> createState() => _MaintenanceAlertScreenState();
}

class _MaintenanceAlertScreenState extends State<MaintenanceAlertScreen> {
  int _days = 30;
  late Future<List<MaintenanceAlert>> _future;

  @override
  void initState() {
    super.initState();
    _future = WorkflowApi.getAlerts(days: _days);
  }

  void _reload() => setState(() => _future = WorkflowApi.getAlerts(days: _days));

  Future<void> _scanNow() async {
    try {
      final result = await WorkflowApi.scanAlerts();
      final data = result['data'] as Map? ?? {};
      if (!mounted) return;
      showCustomSnackBar(context, message: 'Đã quét ${data['scanned'] ?? 0} thiết bị, tạo ${data['created'] ?? 0} cảnh báo mới');
      _reload();
    } on ApiException catch (e) {
      if (mounted) showCustomSnackBar(context, message: e.message, isError: true);
    }
  }

  Color _colorFor(int daysLeft) {
    if (daysLeft <= 7) return Colors.red;
    if (daysLeft <= 15) return Colors.orange;
    return Colors.amber.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cần lập kế hoạch bảo dưỡng'),
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: _scanNow, tooltip: 'Quét ngay', icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('≤ 7 ngày')),
                ButtonSegment(value: 15, label: Text('≤ 15 ngày')),
                ButtonSegment(value: 30, label: Text('≤ 30 ngày')),
              ],
              selected: {_days},
              onSelectionChanged: (s) {
                _days = s.first;
                _reload();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MaintenanceAlert>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString(), style: const TextStyle(color: Colors.red)));
                }
                final alerts = snapshot.data ?? [];
                if (alerts.isEmpty) return const Center(child: Text('Không có thiết bị nào sắp đến hạn'));
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    itemCount: alerts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final a = alerts[index];
                      final due = a.nextMaintenance != null ? DateFormat('dd/MM/yyyy').format(a.nextMaintenance!) : '';
                      final left = a.daysLeft < 0 ? 'Quá hạn ${-a.daysLeft} ngày' : 'Còn ${a.daysLeft} ngày';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _colorFor(a.daysLeft).withOpacity(0.15),
                          child: Icon(Icons.build_circle_outlined, color: _colorFor(a.daysLeft)),
                        ),
                        title: Text(a.title.isNotEmpty ? a.title : a.code),
                        subtitle: Text(a.code.isNotEmpty ? '${a.code} · Hạn bảo dưỡng $due' : 'Hạn bảo dưỡng $due'),
                        trailing: Text(left, style: TextStyle(color: _colorFor(a.daysLeft), fontWeight: FontWeight.bold)),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => DetailDeviceScreen(deviceId: a.id, departmentId: a.departmentId),
                        )),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
