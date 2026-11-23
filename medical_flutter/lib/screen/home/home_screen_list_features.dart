import 'package:flutter/material.dart';
import 'package:medical_device_tracking/animation/slide_from_right_router.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/screen/list_department/list_department_screen.dart';
import 'package:medical_device_tracking/screen/list_device/list_device_screen.dart';
import 'package:medical_device_tracking/screen/list_staff/list_staff_screen.dart';
import 'package:medical_device_tracking/features/user_info_storage/user_info_storage.dart';
import 'package:medical_device_tracking/screen/workflow/maintenance_alert_screen.dart';
import 'package:medical_device_tracking/utils/user_role.dart';

class HomeScreenListFeatures extends StatefulWidget {
  const HomeScreenListFeatures({super.key});

  @override
  State<HomeScreenListFeatures> createState() => _HomeScreenListFeaturesState();
}

class _HomeScreenListFeaturesState extends State<HomeScreenListFeatures> {
  void goToAllDeviceScreen() {
    Navigator.push(
        context,
        SlideFromRightRoute(nextPage: const ListDeviceScreen())
    );
  }

  void goToAllDepartmentScreen() {
    Navigator.push(
        context,
        SlideFromRightRoute(nextPage: const ListDepartmentScreen())
    );
  }

  void goToAllStaffScreen() {
    Navigator.push(
        context,
        SlideFromRightRoute(nextPage: const ListStaffScreen())
    );
  }

  void goToMaintenanceAlertScreen() {
    Navigator.push(
        context,
        SlideFromRightRoute(nextPage: const MaintenanceAlertScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<IconData> featureIcons = [
      Icons.devices_other_outlined,
      Icons.apartment,
      Icons.person,
    ];
    final List<String> featureTitle = [
      'Tất cả thiết bị',
      'Khoa phòng',
      'Nhân viên',
    ];
    final List<EdgeInsets> featurePadding = [
      context.pxy(0.04, 0.02),
      context.px(0.04),
      context.pxy(0.04, 0.02),
    ];

    final List<VoidCallback> featureOnTap = [
      goToAllDeviceScreen,
      goToAllDepartmentScreen,
      goToAllStaffScreen,
    ];

    // FR-04: Dashboard cảnh báo bảo dưỡng chỉ dành cho cán bộ Phòng Vật tư (U3).
    if (UserInfoStorage.getRole() == UserRole.manager) {
      featureIcons.insert(0, Icons.notification_important_outlined);
      featureTitle.insert(0, 'Cảnh báo bảo dưỡng');
      featurePadding.insert(0, context.pxy(0.04, 0.02));
      featureOnTap.insert(0, goToMaintenanceAlertScreen);
    }

    return SliverList.builder(
      itemCount: featureTitle.length,
      itemBuilder: (context, index) {
        return FeaturesCard(
          icon: featureIcons[index],
          title: featureTitle[index],
          padding: featurePadding[index],
          onTap: featureOnTap[index],
        );
      },
    );
  }
}


class FeaturesCard extends StatelessWidget {
  const FeaturesCard({super.key,
    required this.icon,
    required this.title,
    required this.padding,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final EdgeInsets padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.base * 0.18,
        width: context.base * 0.4,
        margin: padding,
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
          children: [
            Expanded(
              flex: 2,
              child: Icon(
                icon,
                color: const Color(0xFF2D82B7),
                size: context.base * 0.09,
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: context.base * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: context.pSM,
                width: context.base * 0.1,
                height: context.base * 0.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2D82B7).withOpacity(0.2),
                ),
                child: Icon(
                  Icons.navigate_next,
                  color: const Color(0xFF2D82B7),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}