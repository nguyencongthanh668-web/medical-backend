import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';

class CustomInputForm extends StatelessWidget {
  const CustomInputForm({super.key,
    required this.controller,
    required this.prefixIcon,
    required this.labelText,
    this.showSuffixIcon = false,
    this.suffixIcon,
    this.isObscure = false,
  });

  final Icon prefixIcon;
  final String labelText;
  final bool showSuffixIcon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final bool isObscure;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.base * 0.18,
      margin: context.pxy(0.04, 0.01),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: context.radiusMD,
                borderSide: BorderSide(
                  width: 3.0,
                  color: Colors.grey.shade100,
                )
            ),
            labelText: labelText,
            prefixIcon: Padding(
                padding: context.pSM,
                child: prefixIcon
            ),
            suffixIcon: Padding(
                padding: context.pSM,
                child: (showSuffixIcon) ? suffixIcon : null
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: context.radiusMD,
                borderSide: BorderSide(
                  width: 2.0,
                  color: AppColors.mainColor,
                )
            )
        ),
      ),
    );
  }
}
