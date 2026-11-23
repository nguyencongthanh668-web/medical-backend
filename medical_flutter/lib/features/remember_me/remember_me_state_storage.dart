import 'package:hive_flutter/hive_flutter.dart';

class RememberMeStateStorage {
  static Future<void> saveRememberMeState({required bool isRememberMe}) async {
    final box = Hive.box('authBox');

    await box.put('isRememberMe', isRememberMe);
  }

  static Future<bool?> getRememberMeState() async {
    final box = Hive.box('authBox');

    return await box.get('isRememberMe');
  }
}