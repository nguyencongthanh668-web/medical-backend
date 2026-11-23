import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/screen/statistical/statistical_appbar.dart';
import 'package:medical_device_tracking/widget/empty_widget/empty_widget.dart';

class StatisticalScreen extends StatelessWidget {
  const StatisticalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          StatisticalAppbar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: context.base * 0.1,),

                EmptyStateBanner(
                  icon: Icons.analytics_outlined,
                  title: 'CHƯA CÓ THỐNG KÊ',
                  message: 'Hiện tại chưa có thống kê nào cho bạn',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
