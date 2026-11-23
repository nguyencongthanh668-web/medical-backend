import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_device_tracking/animation/slide_from_right_router.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/features/get_base_url/get_base_url.dart';
import 'package:medical_device_tracking/screen/login/login_screen.dart';
import 'package:medical_device_tracking/widget/button/custom_filled_button.dart';
import 'package:medical_device_tracking/widget/input/custom_input_form.dart';
import 'package:medical_device_tracking/widget/scaffold/custom_white_scaffold.dart';

class ConfigUrlScreen extends StatefulWidget {
  const ConfigUrlScreen({super.key});

  @override
  State<ConfigUrlScreen> createState() => _ConfigUrlScreenState();
}

class _ConfigUrlScreenState extends State<ConfigUrlScreen> {

  TextEditingController linkController = TextEditingController(
    text: Hive.box('urlBox').get('baseUrl'),
  );

  @override
  Widget build(BuildContext context) {
    return WhiteScaffold(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/svg/medical_device_tracking_logo.svg',
                width: context.base * 0.8,
                height: context.base * 0.8,
              ),
              CustomInputForm(
                controller: linkController,
                prefixIcon: Icon(
                  Icons.link,
                  color: const Color(0xFF2D82B7),
                ),
                labelText: 'Vui lòng điền liên kết ',
              ),
              CustomFilledButton(
                title: 'Liên kết',
                onPressed: () {
                  GetBaseUrl.saveBaseUrl(baseUrl: linkController.text.trim());

                  Navigator.push(
                      context,
                      SlideFromRightRoute(nextPage: const LoginScreen())
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
