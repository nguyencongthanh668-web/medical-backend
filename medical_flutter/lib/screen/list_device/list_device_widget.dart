import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/animation/slide_from_right_router.dart';
import 'package:medical_device_tracking/cubit/all_device/all_device_cubit.dart';
import 'package:medical_device_tracking/cubit/all_device/all_device_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/model/device.dart';
import 'package:medical_device_tracking/screen/detail_device/detail_device_screen.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';

class ListDeviceWidget extends StatefulWidget {
  const ListDeviceWidget({super.key});

  @override
  State<ListDeviceWidget> createState() => _ListDeviceWidgetState();
}

class _ListDeviceWidgetState extends State<ListDeviceWidget> {

  // @override
  // void initState() {
  //   super.initState();
  //   final cubit = context.read<AllDeviceCubit>();
  //   context.read<AllDeviceCubit>().getListDevice(page: 1);
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllDeviceCubit, AllDeviceState>(
      builder: (context, state) {

        if (state.status == AllDeviceLoadingStatus.success) {
          return SliverList.builder(
            itemCount: state.listDevice!.length,
            itemBuilder: (context, index) {
              return DeviceCard(
                title: state.listDevice![index].title,
                model: state.listDevice![index].serial,
                serial: state.listDevice![index].serial,
                status: state.listDevice![index].status,
                deviceInfo: state.listDevice![index],
              );
            },
          );
        }

        return SliverToBoxAdapter();
      },
    );
  }
}

class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key,
    required this.title,
    required this.model,
    required this.serial,
    required this.status,
    required this.deviceInfo,
  });

  final String title;
  final String model;
  final String serial;
  final String status;
  final DeviceModel deviceInfo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlideFromRightRoute(nextPage: DetailDeviceScreen(
            deviceId: deviceInfo.id,
            departmentId: deviceInfo.departmentId,
          ))
        );
      },
      child: Container(
        height: context.base * 0.22,
        margin: context.pxy(0.04, 0.01),
        decoration: BoxDecoration(
            color: Colors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    vertical: context.base * 0.02,
                    horizontal: context.base * 0.02,
                  ),
                  child: Icon(
                    Icons.devices_other_outlined,
                    size: context.base * 0.15,
                    color: AppColors.mainColor,
                  )
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  vertical: context.base * 0.01,
                  horizontal: context.base * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: context.base * 0.038,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: context.base * 0.22,
                            height: context.base * 0.068,
                            decoration: BoxDecoration(
                              color: handleStatusColor(status).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              handleStatusMessage(status),
                              style: TextStyle(
                                fontSize: context.base * 0.026,
                                fontWeight: FontWeight.bold,
                                color: handleStatusColor(status),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: context.base * 0.01
                        ),
                        child: Text(
                          'Model: $model',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: context.base * 0.03
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(
                        'Serial: $serial',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: context.base * 0.03
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Color handleStatusColor(String status) {
  switch(status) {
    case 'active' :
      return Colors.green;
    case 'inactive' :
      return Colors.red;
    case 'corrected' :
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

String handleStatusMessage(String? status) {
  switch (status) {
    case 'not_handed':
      return 'Chưa bàn giao';
    case 'active':
      return 'Đang sử dụng';
    case 'was_broken':
      return 'Đang báo hỏng';
    case 'corrected':
      return 'Đang sửa chữa';
    case 'inactive':
      return 'Ngừng sử dụng';
    case 'liquidated':
      return 'Đã thanh lý';
    case 'all':
      return 'Tất cả';
    default:
      return 'Không xác định';
  }
}

