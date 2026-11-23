class NotificationResponse {
  final int status;
  final List<NotificationModel> data;
  final int total;

  NotificationResponse({
    required this.status,
    required this.data,
    required this.total,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'] ?? 0,
      data: (json['data'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((e) => e.toJson()).toList(),
      'total': total,
    };
  }
}

class NotificationModel {
  final String id;
  final String type;
  final int notifiableId;
  final String notifiableType;
  final NotificationData data;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.notifiableId,
    required this.notifiableType,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      notifiableId: json['notifiable_id'] ?? 0,
      notifiableType: json['notifiable_type'] ?? '',
      data: NotificationData.fromJson(json['data']),
      readAt:
      json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'notifiable_id': notifiableId,
      'notifiable_type': notifiableType,
      'data': data.toJson(),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class NotificationData {
  final int id;
  final int userId;
  final String content;

  NotificationData({
    required this.id,
    required this.userId,
    required this.content,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
    };
  }
}