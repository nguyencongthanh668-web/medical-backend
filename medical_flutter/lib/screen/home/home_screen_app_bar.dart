import 'package:flutter/material.dart';
import 'package:medical_device_tracking/animation/slide_from_right_router.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/screen/list_device/list_device_screen.dart';
import 'package:medical_device_tracking/widget/input/custom_search_bar.dart';

class HomeScreenAppBar extends StatefulWidget {
  const HomeScreenAppBar({super.key});

  @override
  State<HomeScreenAppBar> createState() => _HomeScreenAppBarState();
}

class _HomeScreenAppBarState extends State<HomeScreenAppBar> {

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        expandedHeight: context.base * 0.32,
        pinned: false,
        flexibleSpace: FlexibleSpaceBar(
          background: SafeArea(
            child: Column(
              children: [
                SizedBox(height: context.base * 0.05,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: context.pxy(0.04, 0.01),
                      child: Text(
                        'TRANG TỔNG QUAN',
                        style: TextStyle(
                            fontSize: context.base * 0.05,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: context.base * 0.03,),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        SlideFromRightRoute(nextPage: const ListDeviceScreen())
                    );
                  },
                    child: const CustomSearchBar()),
              ],
            ),
          ),
        )
    );
  }
}
