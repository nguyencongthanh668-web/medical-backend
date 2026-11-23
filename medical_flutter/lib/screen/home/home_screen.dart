import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/all_device/all_device_cubit.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/screen/home/home_screen_actions.dart';
import 'package:medical_device_tracking/screen/home/home_screen_analytics.dart';
import 'package:medical_device_tracking/screen/home/home_screen_app_bar.dart';
import 'package:medical_device_tracking/screen/home/home_screen_list_features.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllDeviceCubit>().getListDevice(page: 1,);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          const HomeScreenAppBar(),

          const HomeScreenAnalytics(),

          SliverToBoxAdapter(
            child: Padding(
              padding: context.pxy(0.04, 0.01),
              child: Text(
                'Thao tác',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: context.base * 0.064,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const HomeScreenActions(),

          const HomeScreenListFeatures(),
        ],
      ),
    );
  }
}
