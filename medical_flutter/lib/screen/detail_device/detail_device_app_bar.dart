import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';

class DetailDeviceAppBar extends StatelessWidget {
  const DetailDeviceAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.mainColor,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Thông tin thiết bị',
        style: TextStyle(
          color: Colors.white,
          fontSize: context.base * 0.058,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
