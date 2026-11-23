import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_device_tracking/animation/slide_from_right_router.dart';
import 'package:medical_device_tracking/cubit/splash/splash_cubit.dart';
import 'package:medical_device_tracking/cubit/splash/splash_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/screen/get_base_url/get_base_url_screen.dart';
import 'package:medical_device_tracking/screen/login/login_screen.dart';
import 'package:medical_device_tracking/utils/app_logo.dart';
import 'package:medical_device_tracking/widget/scaffold/custom_gradient_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    context.read<SplashCubit>().initialApp();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {

        if (state.status == SplashStatus.success) {
          Future.delayed(
              const Duration(seconds: 4),
              () {
                Navigator.pushReplacement(
                    context,
                    SlideFromRightRoute(nextPage: const ConfigUrlScreen())
                );
              }
          );
        }

      },

      child: GradientScaffold(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppLogo.appLogoSvgPath,
                width: context.base * 0.8,
                height: context.base * 0.8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
