import 'package:flutter/material.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key,
    required this.child,
    this.showAppBar = false,
    this.appBar,
  });

  final Widget child;
  final bool showAppBar;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (showAppBar) ? appBar : null ,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.splashFirstColor,
              AppColors.splashSecondColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}
