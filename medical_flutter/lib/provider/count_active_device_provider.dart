import 'package:flutter/material.dart';
import 'package:medical_device_tracking/features/count_device_storage/get_count_active_device.dart';
import 'package:medical_device_tracking/features/count_device_storage/get_count_device.dart';

class CountActiveDeviceProvider extends ChangeNotifier {
  int _countActiveDevice = 0;
  int get countActiveDevice => _countActiveDevice;

  Future<void> getCountActiveDevice() async {
    final int count = await GetCountActiveDevice.getCountActiveDevice();

    _countActiveDevice = count;

    notifyListeners();
  }
}