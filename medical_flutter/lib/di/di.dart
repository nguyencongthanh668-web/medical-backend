import 'package:get_it/get_it.dart';
import 'package:medical_device_tracking/network/dio_config/dio_config.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<DioConfig>(
      () => DioConfig()
  );
}