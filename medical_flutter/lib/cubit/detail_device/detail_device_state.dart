import 'package:equatable/equatable.dart';
import 'package:medical_device_tracking/model/device.dart';

enum DetailDeviceLoadStatus {initial, loading, success, failure}

class DetailDeviceState extends Equatable {
  final DetailDeviceLoadStatus status;
  final DeviceDetailModel? deviceInfo;
  final String? message;

  const DetailDeviceState({required this.status,
    this.deviceInfo,
    this.message,
  });

  DetailDeviceState copyWith({DetailDeviceLoadStatus? status,
    DeviceDetailModel? deviceInfo,
    String? message,
  }) {
    return DetailDeviceState(
      status: status ?? this.status,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      message: message ?? this.message
    );
  }

  @override
  List<Object?> get props => [
    status,
    deviceInfo,
    message,
  ];
}