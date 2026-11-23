import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';

class DetailDeviceCustomBg extends StatelessWidget {
  const DetailDeviceCustomBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(0,-2.35),
      child: Container(
        height: context.base * 1.2,
        decoration: BoxDecoration(
            color: AppColors.mainColor,
            borderRadius: BorderRadius.circular(36)
        ),
      ),
    );
  }
}