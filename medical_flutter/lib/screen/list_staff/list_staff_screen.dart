import 'package:flutter/material.dart';
import 'package:medical_device_tracking/screen/list_staff/list_staff_appbar.dart';
import 'package:medical_device_tracking/screen/list_staff/list_staff_widget.dart';

class ListStaffScreen extends StatelessWidget {
  const ListStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          ListStaffAppbar(),
          ListStaffWidget(),
        ],
      ),
    );
  }
}
