import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/detail_device/detail_device_cubit.dart';
import 'package:medical_device_tracking/cubit/detail_device/detail_device_state.dart';
import 'package:medical_device_tracking/cubit/history/history_cubit.dart';
import 'package:medical_device_tracking/cubit/report_device/report_device_cubit.dart';
import 'package:medical_device_tracking/cubit/report_device/report_device_state.dart';
import 'package:medical_device_tracking/provider/get_detail_department_provider.dart';
import 'package:medical_device_tracking/screen/detail_device/detail_device_app_bar.dart';
import 'package:medical_device_tracking/screen/detail_device/detail_device_bottom_nav.dart';
import 'package:medical_device_tracking/screen/detail_device/detail_device_card.dart';
import 'package:medical_device_tracking/screen/detail_device/detail_device_custom_bg.dart';
import 'package:medical_device_tracking/screen/detail_device/detail_device_info_card.dart';
import 'package:medical_device_tracking/screen/detail_device/detail_device_time_line.dart';
import 'package:medical_device_tracking/widget/button/custom_filled_button.dart';
import 'package:medical_device_tracking/widget/snack_bar/custom_snackbar.dart';

class DetailDeviceScreen extends StatefulWidget {
  const DetailDeviceScreen({super.key,
    required this.deviceId,
    required this.departmentId,
  });

  final int deviceId;
  final int departmentId;

  @override
  State<DetailDeviceScreen> createState() => _DetailDeviceScreenState();
}

class _DetailDeviceScreenState extends State<DetailDeviceScreen> {
  
  @override
  void initState() {
    super.initState();
    context.read<DetailDeviceCubit>().getDetailDevice(id: widget.deviceId);
    context.read<HistoryCubit>().load(widget.deviceId);
    context.read<GetDetailDepartmentProvider>().getDetailDepartment(id: widget.departmentId);
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailDeviceCubit, DetailDeviceState>(
      builder: (context, state) {
        return Scaffold(
            backgroundColor: Colors.grey.shade100,
            bottomNavigationBar: DetailDeviceBottomNav(deviceId: widget.deviceId),
            body: Stack(
              children: [
                const DetailDeviceCustomBg(),

                CustomScrollView(
                  slivers: [
                    const DetailDeviceAppBar(),
                    const DetailDeviceCard(),
                    const DetailDeviceInfoCard(),
                    const DetailDeviceTimeline(),
                  ],
                )
              ],
            )
        );
      },
    );
  }
}
