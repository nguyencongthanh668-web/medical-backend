import 'package:flutter/material.dart';
import 'package:medical_device_tracking/animation/slide_from_right_router.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/features/scan_qr_code/scan_qr_code.dart';
import 'package:medical_device_tracking/features/user_info_storage/user_info_storage.dart';
import 'package:medical_device_tracking/features/workflow/workflow_api.dart';
import 'package:medical_device_tracking/screen/detail_device/detail_device_screen.dart';
import 'package:medical_device_tracking/screen/scan_qr_code/scan_qr_code_screen.dart';
import 'package:medical_device_tracking/screen/workflow/create_equipment_screen.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';
import 'package:medical_device_tracking/utils/user_role.dart';
import 'package:medical_device_tracking/widget/snack_bar/custom_snackbar.dart';

class HomeScreenActions extends StatelessWidget {
  const HomeScreenActions({super.key});

  // FR-01: chỉ cán bộ Phòng Vật tư (U3) được lập hồ sơ thiết bị.
  void _addDevice(BuildContext context) {
    if (UserInfoStorage.getRole() != UserRole.manager) {
      showCustomSnackBar(context, message: 'Chỉ cán bộ Phòng Vật tư được thêm thiết bị', isError: true);
      return;
    }
    Navigator.push(context, SlideFromRightRoute(nextPage: const CreateEquipmentScreen()));
  }

  // UC-02, UC-05: quét QR trên máy để mở hồ sơ, từ đó báo hỏng hoặc xem lịch sử.
  Future<void> _scan(BuildContext context) async {
    final code = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const QrScanScreen()));
    if (code == null || !context.mounted) return;
    try {
      final device = await ScanQrCode.resolve(code);
      if (!context.mounted) return;
      Navigator.push(context, SlideFromRightRoute(nextPage: DetailDeviceScreen(
        deviceId: device['id']!,
        departmentId: device['department_id']!,
      )));
    } on ApiException catch (e) {
      if (context.mounted) showCustomSnackBar(context, message: e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          Expanded(
            child: HomeActionButton(
              icon: Icons.add_circle,
              title: 'Thêm thiết bị',
              padding: context.pOnly(0.01, 0.04, 0.01, 0.01),
              onTap: () => _addDevice(context),
            ),
          ),
          Expanded(
            child: HomeActionButton(
              icon: Icons.qr_code_scanner,
              title: 'Quét mã',
              padding: context.pOnly(0.01, 0.01, 0.01, 0.04),
              onTap: () => _scan(context),
            ),
          )
        ],
      ),
    );
  }
}

class HomeActionButton extends StatelessWidget {
  const HomeActionButton({super.key,
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
    return Container(
      height: context.base * 0.12,
      width: context.base * 0.4,
      margin: padding,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: context.radiusMD,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: context.base * 0.09,
            ),
            Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: context.base * 0.035
              ),
            )
          ],
        ),
      ),
    );
  }
}
