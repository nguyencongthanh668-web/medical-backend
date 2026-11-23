import 'package:flutter/material.dart';
import 'package:medical_device_tracking/features/count_device_storage/get_count_device.dart';

class CountDeviceProvider extends ChangeNotifier {
  int _countDevice = 0;
  int get countDevice => _countDevice;

  Future<void> getCountDevice() async {
    final int count = await GetCountDevice.getCountDevice();

    _countDevice = count;

    notifyListeners();
  }
}