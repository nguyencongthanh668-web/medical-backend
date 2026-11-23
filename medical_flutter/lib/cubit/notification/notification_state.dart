import 'package:equatable/equatable.dart';
import 'package:medical_device_tracking/model/notification.dart';

enum NotificationStatus {initial, loading, success, failure}

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationModel>? listNotification;

  const NotificationState({required this.status,
    this.listNotification,
  });

  NotificationState copyWith({NotificationStatus? status,
    List<NotificationModel>? listNotification,
  }) {
    return NotificationState(
      status: status ?? this.status,
      listNotification: listNotification ?? this.listNotification,
    );
  }

  @override
  List<Object?> get props => [
    status,
    listNotification,
  ];
}