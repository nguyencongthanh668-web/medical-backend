import 'package:flutter/material.dart';
import 'package:medical_device_tracking/screen/list_department/list_department_appbar.dart';
import 'package:medical_device_tracking/screen/list_department/list_department_widget.dart';

class ListDepartmentScreen extends StatelessWidget {
  const ListDepartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          const ListDepartmentAppbar(),
          const ListDepartmentWidget(),
        ],
      ),
    );
  }
}
