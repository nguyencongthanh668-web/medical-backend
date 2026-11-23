import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical_device_tracking/animation/slide_from_right_router.dart';
import 'package:medical_device_tracking/cubit/login/login_cubit.dart';
import 'package:medical_device_tracking/cubit/login/login_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/screen/home/home_screen.dart';
import 'package:medical_device_tracking/screen/nav/nav_router.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';
import 'package:medical_device_tracking/utils/app_logo.dart';
import 'package:medical_device_tracking/widget/button/custom_filled_button.dart';
import 'package:medical_device_tracking/widget/input/custom_input_form.dart';
import 'package:medical_device_tracking/widget/scaffold/custom_white_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        
        if (state.status == LoginStatus.success) {
          Navigator.pushReplacement(
            context,
            SlideFromRightRoute(nextPage: const NavRouter())
          );
        }
        
      },
      
      child: WhiteScaffold(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppLogo.appLogoSvgPath,
                    width: context.base * 0.8,
                    height: context.base * 0.8,
                  ),
                    
                  Text(
                    'Chào mừng trở lại',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: context.base * 0.07,
                      fontFamily: 'Inter',
                    ),
                  ),
                    
                  SizedBox(height: context.base * 0.05,),
                    
                  CustomInputForm(
                    controller: usernameController,
                    prefixIcon: Icon(
                      Icons.person,
                      color: AppColors.mainColor,
                    ),
                    labelText: 'Tên đăng nhập',
                  ),
                    
                  CustomInputForm(
                      controller: passwordController,
                      isObscure: isObscure,
                      prefixIcon: Icon(
                        Icons.lock,
                        color: AppColors.mainColor,
                      ),
                      labelText: 'Mật khẩu',
                      showSuffixIcon: true,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                        child: (isObscure) ? Icon(Icons.remove_red_eye) : Icon(Icons.remove_red_eye_outlined),
                      )
                  ),
                    
                  SizedBox(height: context.base * 0.05,),
                    
                  CustomFilledButton(
                    title: 'Đăng nhập',
                    onPressed: () {
                      context.read<LoginCubit>().login(
                        username: usernameController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
