import 'package:medical_device_tracking/model/device.dart';

class CountDeviceAnalytic {
  final String status;
  final List<DeviceModel> data;
  final int dataLength;

  CountDeviceAnalytic({
    required this.status,
    required this.data,
    required this.dataLength,
  });

  factory CountDeviceAnalytic.fromJson(Map<String, dynamic> json) {
    return CountDeviceAnalytic(
      status: json['status'] as String,
      data: (json['data'] as List)
          .map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      dataLength: json['dataLength'],
    );
  }
}
