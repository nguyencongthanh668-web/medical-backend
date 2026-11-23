import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/provider/count_active_device_provider.dart';
import 'package:medical_device_tracking/provider/count_corrected_device_provider.dart';
import 'package:medical_device_tracking/provider/count_device_provider.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';
import 'package:provider/provider.dart';

class HomeScreenAnalytics extends StatefulWidget {
  const HomeScreenAnalytics({super.key});

  @override
  State<HomeScreenAnalytics> createState() => _HomeScreenAnalyticsState();
}

class _HomeScreenAnalyticsState extends State<HomeScreenAnalytics> {

  @override
  void initState() {
    super.initState();
    context.read<CountDeviceProvider>().getCountDevice();
    context.read<CountActiveDeviceProvider>().getCountActiveDevice();
    context.read<CountCorrectedDeviceProvider>().getCountCorrectedDevice();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SingleAnalyticsCard(
            title: 'Tổng số thiết bị',
            value: context.watch<CountDeviceProvider>().countDevice.toString(),
            icon: Icons.devices_other_outlined,
          ),

          Row(
            children: [
              Expanded(
                child: DoubleAnalyticCard(
                  title: 'Hoạt động',
                  icon: Icons.run_circle_outlined,
                  padding: context.pOnly(0.01, 0.04, 0.01, 0.01),
                  value: context.watch<CountActiveDeviceProvider>().countActiveDevice.toString(),
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: DoubleAnalyticCard(
                  title: 'Đang bảo trì',
                  value: context.watch<CountCorrectedDeviceProvider>().countCorrectedDevice.toString(),
                  icon: Icons.settings_outlined,
                  padding: context.pOnly(0.01, 0.01, 0.01, 0.04),
                  color: Colors.red,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class SingleAnalyticsCard extends StatelessWidget {
  const SingleAnalyticsCard({super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;


  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.base * 0.28,
      margin: context.pOnly(0.02, 0.04, 0.01, 0.04),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              left: BorderSide(width: 10, color: AppColors.mainColor)
          ),
          borderRadius: context.radiusMD,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -1,
            ),
          ]
      ),
      child: Row(
        children: [
          Padding(
            padding: context.pxy(0.04, 0.01),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                    fontSize: context.base * 0.04,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.mainColor,
                    fontSize: context.base * 0.08,
                    fontWeight: FontWeight.w900,
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: Container(
              alignment: Alignment.topRight,
              child: Container(
                margin: context.pxy(0.04, 0.01),
                width: context.base * 0.1,
                height: context.base * 0.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mainColor.withOpacity(0.3),
                ),
                child: Icon(
                  icon,
                  color: AppColors.mainColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DoubleAnalyticCard extends StatelessWidget {
  const DoubleAnalyticCard({super.key,
    required this.title,
    required this.icon,
    required this.padding,
    required this.value,
    required this.color,
  });

  final String title;
  final IconData icon;
  final EdgeInsets padding;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.base * 0.28,
      width: context.base * 0.4,
      margin: padding,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              left: BorderSide(width: 10, color: AppColors.mainColor,)),
          borderRadius: context.radiusMD,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -1,
            ),
          ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                  fontSize: context.base * 0.04,
                ),
              ),
              Container(
                margin: context.pxy(0.04, 0.01) * 0.1,
                width: context.base * 0.1,
                height: context.base * 0.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mainColor.withOpacity(0.3),
                ),
                child: Icon(
                  icon,
                  color: AppColors.mainColor,
                ),
              ),
            ],
          ),

          Padding(
            padding: context.pxy(0.04, 0.01),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: context.base * 0.08,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        ],
      ),
    );
  }
}
