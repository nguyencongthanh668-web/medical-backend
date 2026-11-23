import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/widget/input/custom_search_bar.dart';

class ListStaffAppbar extends StatelessWidget {
  const ListStaffAppbar({super.key});

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
                    'Danh sách nhân viên',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: context.base * 0.058,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              CustomSearchBar(),
            ],
          ),
        ),
      ),
    );;
  }
}
