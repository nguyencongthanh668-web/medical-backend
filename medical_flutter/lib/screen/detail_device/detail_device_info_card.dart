import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/detail_device/detail_device_cubit.dart';
import 'package:medical_device_tracking/cubit/detail_device/detail_device_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';

class DetailDeviceInfoCard extends StatelessWidget {
  const DetailDeviceInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailDeviceCubit, DetailDeviceState>(
      builder: (context, state) {
        return SliverToBoxAdapter(
          child: Container(
            height: context.base * 0.38,
            margin: context.pxy(0.04, 0.01),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: context.radiusMD,
            ),
            child: Padding(
              padding: context.pxy(0.04, 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông số kỹ thuật',
                    style: TextStyle(
                      fontSize: context.base * 0.044,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Model:',
                        style: TextStyle(
                            fontSize: context.base * 0.032
                        ),
                      ),
                      Text(
                        state.deviceInfo?.model.toString() ?? '',
                        style: TextStyle(
                            fontSize: context.base * 0.032
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Số Serial:',
                        style: TextStyle(
                            fontSize: context.base * 0.032
                        ),
                      ),
                      Text(
                        state.deviceInfo?.serial.toString() ?? '',
                        style: TextStyle(
                            fontSize: context.base * 0.032
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nhà sản xuất:',
                        style: TextStyle(
                            fontSize: context.base * 0.032
                        ),
                      ),
                      Text(
                        state.deviceInfo?.manufacturer ?? '',
                        style: TextStyle(
                            fontSize: context.base * 0.032
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ngày sản xuất:',
                        style: TextStyle(
                            fontSize: context.base * 0.032
                        ),
                      ),
                      Text(
                        state.deviceInfo?.yearManufacture ?? '',
                        style: TextStyle(
                            fontSize: context.base * 0.032
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Năm sử dụng:',
                        style: TextStyle(
                            fontSize: context.base * 0.032
                        ),
                      ),
                      Text(
                        state.deviceInfo?.yearUse ?? '',
                        style: TextStyle(
                            fontSize: context.base * 0.032
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
