import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/detail_device/detail_device_cubit.dart';
import 'package:medical_device_tracking/cubit/detail_device/detail_device_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/provider/get_detail_department_provider.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';

class DetailDeviceCard extends StatelessWidget {
  const DetailDeviceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final info = context.watch<GetDetailDepartmentProvider>().departmentInfo;

    return BlocBuilder<DetailDeviceCubit, DetailDeviceState>(
      builder: (context, state) {
        return SliverToBoxAdapter(
          child: Container(
            height: context.base * 0.6,
            margin: context.pxy(0.04, 0.04),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: context.radiusMD
            ),
            child: Column(
              children: [
                Expanded(
                    flex: 4,
                    child: Container(
                      width: context.base * 0.84,
                      height: context.base * 0.38,
                      margin: context.pxy(0.04, 0.01),
                      child: ClipRRect(
                          borderRadius: context.radiusMD,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                                padding: EdgeInsetsGeometry.symmetric(
                                  vertical: context.base * 0.02,
                                  horizontal: context.base * 0.02,
                                ),
                                child: Icon(
                                  Icons.devices_other_outlined,
                                  size: context.base * 0.25,
                                  color: AppColors.mainColor,
                                )
                            ),
                          ),),
                    )
                ),
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: context.pxy(0.04, 0.01),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.deviceInfo?.title ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: context.base * 0.058,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: Colors.black54,),
                              SizedBox(width: context.base * 0.02,),
                              Text(
                                info?.title ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: context.base * 0.04,
                                  color: Colors.black54,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
