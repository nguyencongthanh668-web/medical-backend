import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/all_device/all_device_cubit.dart';
import 'package:medical_device_tracking/cubit/all_device/all_device_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';

class ListDevicePageIndex extends StatelessWidget {
  const ListDevicePageIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllDeviceCubit, AllDeviceState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.base * 0.08),
                topRight: Radius.circular(context.base * 0.08),
              ),
              border: Border.all(color: Colors.grey.shade400,width: 1.5)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Tooltip(
                message: 'Trang trước',
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: context.base * 0.05,),
                  onPressed: () {
                    context.read<AllDeviceCubit>().previousPage();
                  },
                ),
              ),

              Text(
                state.pageIndex.toString(),
                style: TextStyle(
                  fontSize: context.base * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Tooltip(
                message: 'Trang sau',
                child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios, size: context.base * 0.05,),
                  onPressed: () {
                    context.read<AllDeviceCubit>().nextPage();
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
