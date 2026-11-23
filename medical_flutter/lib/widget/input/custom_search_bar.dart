import 'package:flutter/material.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.pxy(0.04, 0.01),
      width: double.infinity,
      height: context.base * 0.10,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: context.radiusMD,
      ),
      child: Row(
        children: [
          Padding(
            padding: context.pSM,
            child: Icon(
              Icons.search,
            ),
          ),
          Text('Tìm kiếm thiết bị ...')
        ],
      ),
    );
  }
}