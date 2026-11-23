import 'package:flutter/material.dart';
import 'package:medical_device_tracking/features/detail_department/get_detail_department.dart';
import 'package:medical_device_tracking/model/department.dart';

class GetDetailDepartmentProvider extends ChangeNotifier {
  DepartmentModel? _departmentInfo;
  DepartmentModel? get departmentInfo => _departmentInfo;

  Future<void> getDetailDepartment({required int id}) async {
    final DepartmentModel? info = await GetDetailDepartment.getDetailDepartment(id: id);

    _departmentInfo = info;

    notifyListeners();
  }
}