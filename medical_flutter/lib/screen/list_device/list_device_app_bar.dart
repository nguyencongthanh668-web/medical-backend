import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/all_device/all_device_cubit.dart';
import 'package:medical_device_tracking/cubit/all_device/all_device_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/screen/list_device/list_device_widget.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';
import 'package:medical_device_tracking/widget/input/custom_search_bar.dart';

class ListDeviceAppBar extends StatelessWidget {
  const ListDeviceAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      expandedHeight: context.base * 0.38,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios)),
                  Text(
                    'Danh sách thiết bị',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: context.base * 0.058,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              CustomSearchBar(),

              Expanded(
                child: BlocBuilder<AllDeviceCubit, AllDeviceState>(
                  builder: (context, state) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: DeviceStatus.values.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            context.read<AllDeviceCubit>().setQueryStatus(
                              queryStatus: DeviceStatus.values[index]
                            );
                          },
                          child: FilterTab(
                            isFocus: (DeviceStatus.values[index] == state.queryStatus),
                            title: handleStatusMessage(DeviceStatus.values[index].name),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FilterTab extends StatelessWidget {
  const FilterTab({super.key,
    required this.isFocus,
    required this.title,
  });

  final bool isFocus;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: context.base * 0.22,
      height: context.base * 0.13,
      margin: context.pxy(0.04, 0.03),
      decoration: BoxDecoration(
          color: (isFocus) ? AppColors.mainColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: (isFocus) ? AppColors.mainColor : Colors.black54
          )
      ),
      child: Text(
        title,
        style: TextStyle(
            color: (isFocus) ? Colors.white : Colors.black54,
            fontSize: context.base * 0.028,
            fontWeight: FontWeight.w500
        ),
      ),
    );
  }
}

