import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_device_tracking/cubit/all_department/all_department_cubit.dart';
import 'package:medical_device_tracking/cubit/all_device/all_device_cubit.dart';
import 'package:medical_device_tracking/cubit/all_staff/all_staff_cubit.dart';
import 'package:medical_device_tracking/cubit/detail_device/detail_device_cubit.dart';
import 'package:medical_device_tracking/cubit/history/history_cubit.dart';
import 'package:medical_device_tracking/cubit/login/login_cubit.dart';
import 'package:medical_device_tracking/cubit/logout/logout_cubit.dart';
import 'package:medical_device_tracking/cubit/notification/notification_cubit.dart';
import 'package:medical_device_tracking/cubit/profile/profile_cubit.dart';
import 'package:medical_device_tracking/cubit/report_device/report_device_cubit.dart';
import 'package:medical_device_tracking/cubit/splash/splash_cubit.dart';
import 'package:medical_device_tracking/di/di.dart';
import 'package:medical_device_tracking/provider/count_active_device_provider.dart';
import 'package:medical_device_tracking/provider/count_corrected_device_provider.dart';
import 'package:medical_device_tracking/provider/count_device_provider.dart';
import 'package:medical_device_tracking/provider/get_detail_department_provider.dart';
import 'package:medical_device_tracking/screen/splash/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await Hive.openBox('urlBox');
  setupLocator();

  runApp(const MedicalDeviceTrackingApp());
}

class MedicalDeviceTrackingApp extends StatelessWidget {
  const MedicalDeviceTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {FocusScope.of(context).unfocus();},
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => CountDeviceProvider()..getCountDevice(),
          ),
          ChangeNotifierProvider(
            create: (_) => CountActiveDeviceProvider()..getCountActiveDevice(),
          ),
          ChangeNotifierProvider(
            create: (_) => CountCorrectedDeviceProvider()..getCountCorrectedDevice(),
          ),
          ChangeNotifierProvider(
            create: (_) => GetDetailDepartmentProvider(),
          )
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SplashCubit()),
            BlocProvider(create: (_) => LoginCubit()),
            BlocProvider(create: (_) => AllDeviceCubit()),
            BlocProvider(create: (_) => DetailDeviceCubit()),
            BlocProvider(create: (_) => HistoryCubit()),
            BlocProvider(create: (_) => ReportDeviceCubit()),
            BlocProvider(create: (_) => AllDepartmentCubit()),
            BlocProvider(create: (_) => NotificationCubit()),
            BlocProvider(create: (_) => AllStaffCubit()),
            BlocProvider(create: (_) => ProfileCubit()),
            BlocProvider(create: (_) => LogoutCubit(),)
          ],
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          ),
        ),
      ),
    );
  }
}


