import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/animation/slide_from_right_router.dart';
import 'package:medical_device_tracking/cubit/logout/logout_cubit.dart';
import 'package:medical_device_tracking/cubit/logout/logout_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/features/get_base_url/get_base_url.dart';
import 'package:medical_device_tracking/screen/get_base_url/get_base_url_screen.dart';
import 'package:medical_device_tracking/widget/snack_bar/custom_snackbar.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key,});

  @override
  Widget build(BuildContext context) {
    final base = context.base;

    return BlocListener<LogoutCubit, LogoutState>(
      listener: (context, state) {

        if (state.status == LogoutStatus.success) {
          showCustomSnackBar(
            context,
            message: 'Đăng xuất thành công',
          );

          Navigator.pushReplacement(
              context,
              SlideFromRightRoute(nextPage: const ConfigUrlScreen())
          );
        }

      },

      child: GestureDetector(
        onTap: () {
          context.read<LogoutCubit>().logout();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: base * 0.045,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(base * 0.06),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: base * 0.04,
                offset: Offset(0, base * 0.015),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                color: const Color(0xFFE04F5F),
                size: base * 0.055,
              ),
              SizedBox(width: base * 0.025),
              Text(
                "Đăng xuất",
                style: TextStyle(
                  color: const Color(0xFFE04F5F),
                  fontSize: base * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}