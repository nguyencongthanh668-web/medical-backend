import 'package:medical_device_tracking/model/device.dart';

class ListDeviceResponse {
  final String status;
  final DeviceData data;
  final int dataLength;

  ListDeviceResponse({
    required this.status,
    required this.data,
    required this.dataLength,
  });

  factory ListDeviceResponse.fromJson(Map<String, dynamic> json) {
    return ListDeviceResponse(
      status: json['status'],
      data: DeviceData.fromJson(json['data']),
      dataLength: json['dataLength'],
    );
  }
}

class DeviceData {
  final int currentPage;
  final List<DeviceModel> data;
  final int perPage;
  final int from;
  final int to;
  final String path;
  final String? nextPageUrl;
  final String? prevPageUrl;

  DeviceData({
    required this.currentPage,
    required this.data,
    required this.perPage,
    required this.from,
    required this.to,
    required this.path,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      currentPage: json['current_page'],
      data: List<DeviceModel>.from(
        json['data'].map((x) => DeviceModel.fromJson(x)),
      ),
      perPage: json['per_page'],
      from: json['from'],
      to: json['to'],
      path: json['path'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}
