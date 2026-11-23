import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/screen/list_device/list_device_app_bar.dart';
import 'package:medical_device_tracking/screen/list_device/list_device_page_index.dart';
import 'package:medical_device_tracking/screen/list_device/list_device_widget.dart';

class ListDeviceScreen extends StatelessWidget {
  const ListDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: const ListDevicePageIndex(),
      body: CustomScrollView(
        slivers: [
          const ListDeviceAppBar(),
          const ListDeviceWidget(),
        ],
      ),
    );
  }
}
