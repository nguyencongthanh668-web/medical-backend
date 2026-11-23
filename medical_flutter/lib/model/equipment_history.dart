/// Lịch sử thiết bị trả về từ GET api/v1/equipments/:id/history (FR-05).
class HistoryEvent {
  final String kind; // fault | inspection | repair | maintenance
  final String title;
  final String detail;
  final String? person;
  final DateTime? time;
  final double? cost;
  final String? result;

  HistoryEvent({
    required this.kind,
    required this.title,
    required this.detail,
    this.person,
    this.time,
    this.cost,
    this.result,
  });

  factory HistoryEvent.fromJson(Map<String, dynamic> json) {
    return HistoryEvent(
      kind: json['kind'] ?? '',
      title: json['title'] ?? '',
      detail: json['detail'] ?? '',
      person: json['person'],
      time: json['time'] != null ? DateTime.tryParse(json['time'])?.toLocal() : null,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      result: json['result'],
    );
  }
}

class HistorySummary {
  final int failureCount;
  final int repairCount;
  final int maintenanceCount;
  final double totalCost;

  HistorySummary({
    required this.failureCount,
    required this.repairCount,
    required this.maintenanceCount,
    required this.totalCost,
  });

  factory HistorySummary.fromJson(Map<String, dynamic> json) {
    return HistorySummary(
      failureCount: json['failure_count'] ?? 0,
      repairCount: json['repair_count'] ?? 0,
      maintenanceCount: json['maintenance_count'] ?? 0,
      totalCost: ((json['total_cost'] ?? 0) as num).toDouble(),
    );
  }
}

class EquipmentHistory {
  final HistorySummary summary;
  final List<HistoryEvent> events;

  EquipmentHistory({required this.summary, required this.events});

  factory EquipmentHistory.fromJson(Map<String, dynamic> json) {
    return EquipmentHistory(
      summary: HistorySummary.fromJson(json['summary'] ?? {}),
      events: (json['events'] as List<dynamic>? ?? [])
          .map((e) => HistoryEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Một thiết bị sắp đến hạn bảo dưỡng (GET api/v1/maintenance-alerts, FR-04).
class MaintenanceAlert {
  final int id;
  final String title;
  final String code;
  final int departmentId;
  final String status;
  final DateTime? nextMaintenance;
  final int daysLeft;
  final int? alertedMilestone;

  MaintenanceAlert({
    required this.id,
    required this.title,
    required this.code,
    required this.departmentId,
    required this.status,
    required this.nextMaintenance,
    required this.daysLeft,
    this.alertedMilestone,
  });

  factory MaintenanceAlert.fromJson(Map<String, dynamic> json) {
    return MaintenanceAlert(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      departmentId: json['department_id'] ?? 0,
      status: json['status'] ?? '',
      nextMaintenance: json['next_maintenance'] != null ? DateTime.tryParse(json['next_maintenance']) : null,
      daysLeft: json['days_left'] ?? 0,
      alertedMilestone: json['alerted_milestone'],
    );
  }
}
