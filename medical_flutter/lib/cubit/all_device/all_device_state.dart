import 'package:equatable/equatable.dart';
import 'package:medical_device_tracking/model/device.dart';

enum AllDeviceLoadingStatus {initial, loading, success, failure}
enum DeviceStatus {all, active, was_broken, corrected, inactive, liquidated, not_handed }

class AllDeviceState extends Equatable {
  final AllDeviceLoadingStatus status;
  final String? message;
  final int pageIndex;
  final DeviceStatus queryStatus;
  final List<DeviceModel>? listDevice;

  const AllDeviceState({required this.status,
    this.message,
    this.pageIndex = 1,
    this.queryStatus = DeviceStatus.all,
    this.listDevice,
  });

  AllDeviceState copyWith({AllDeviceLoadingStatus? status,
    String? message,
    int? pageIndex,
    DeviceStatus? queryStatus,
    List<DeviceModel>? listDevice,
  }) {
    return AllDeviceState(
      status: status ?? this.status,
      message: message ?? this.message,
      pageIndex: pageIndex ?? this.pageIndex,
      queryStatus: queryStatus ?? this.queryStatus,
      listDevice: listDevice ?? this.listDevice,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
    pageIndex,
    queryStatus,
    listDevice,
  ];
}