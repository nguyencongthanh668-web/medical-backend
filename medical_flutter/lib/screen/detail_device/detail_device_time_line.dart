import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medical_device_tracking/cubit/history/history_cubit.dart';
import 'package:medical_device_tracking/cubit/history/history_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/model/equipment_history.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';

/// Timeline "lịch sử khám bệnh" của thiết bị (FR-05): số lần hỏng, chi phí và từng sự kiện.
class DetailDeviceTimeline extends StatelessWidget {
  const DetailDeviceTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        Widget body;
        if (state.status == HistoryStatus.loading || state.status == HistoryStatus.initial) {
          body = const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
        } else if (state.status == HistoryStatus.failure) {
          body = Padding(
            padding: const EdgeInsets.all(16),
            child: Text(state.message ?? 'Không tải được lịch sử', style: const TextStyle(color: Colors.red)),
          );
        } else {
          final history = state.history!;
          body = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryRow(summary: history.summary),
              if (history.events.isEmpty)
                const Padding(padding: EdgeInsets.all(16), child: Text('Chưa có sự kiện nào'))
              else
                ...history.events.map((e) => TimeWidget(event: e)),
            ],
          );
        }

        return SliverToBoxAdapter(
          child: Container(
            margin: context.pxy(0.04, 0.03),
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: context.radiusMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: context.pxy(0.04, 0.02),
                  child: Text(
                    'Lịch sử thiết bị',
                    style: TextStyle(fontSize: context.base * 0.044, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                body,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final HistorySummary summary;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.decimalPattern('vi_VN');
    Widget item(String label, String value) => Expanded(
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          item('Lần hỏng', '${summary.failureCount}'),
          item('Lần sửa', '${summary.repairCount}'),
          item('Lần bảo dưỡng', '${summary.maintenanceCount}'),
          item('Tổng chi phí (đ)', money.format(summary.totalCost)),
        ],
      ),
    );
  }
}

class TimeWidget extends StatelessWidget {
  const TimeWidget({super.key, required this.event});

  final HistoryEvent event;

  IconData get _icon {
    switch (event.kind) {
      case 'fault':
        return Icons.report_problem_outlined;
      case 'inspection':
        return Icons.search;
      case 'maintenance':
        return Icons.build_circle_outlined;
      default:
        return Icons.settings_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = event.time != null ? DateFormat('dd/MM/yyyy').format(event.time!) : '';
    final money = NumberFormat.decimalPattern('vi_VN');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.mainColor.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(_icon, color: AppColors.mainColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (event.detail.isNotEmpty) Text(event.detail, style: const TextStyle(color: Colors.black87)),
                if (event.person != null)
                  Text('Người thực hiện: ${event.person}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                if (event.cost != null && event.cost! > 0)
                  Text('Chi phí: ${money.format(event.cost)} đ', style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
