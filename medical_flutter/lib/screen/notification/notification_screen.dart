import 'package:flutter/material.dart';
import 'package:medical_device_tracking/screen/notification/notification_appbar.dart';
import 'package:medical_device_tracking/screen/notification/notification_widget.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          NotificationAppbar(),
          NotificationWidget(),
        ],
      ),
    );
  }
}
