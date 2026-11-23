import 'package:flutter/material.dart';
import 'package:medical_device_tracking/features/count_device_storage/get_count_corrected_device.dart';

class CountCorrectedDeviceProvider extends ChangeNotifier {
  int _countCorrectedDevice = 0;
  int get countCorrectedDevice => _countCorrectedDevice;

  Future<void> getCountCorrectedDevice() async {
    final int count = await GetCountCorrectedDevice.getCountCorrectedDevice();

    _countCorrectedDevice = count;

    notifyListeners();
  }
}