import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';

class ProfileScreenAppbar extends StatelessWidget {
  const ProfileScreenAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      expandedHeight: context.base * 0.18,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(width: context.base * 0.05,),
                  Text(
                    'Thông tin cá nhân',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: context.base * 0.058,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
