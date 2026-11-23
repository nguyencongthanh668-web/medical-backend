import 'package:hive_flutter/hive_flutter.dart';

class TokenStorage {
  static Future<void> saveToken({required String token}) async {
    final box = Hive.box('authBox');

    await box.put('accessToken', token);
  }

  static Future<String?> getToken() async {
    final box = Hive.box('authBox');

    return await box.get('accessToken');
  }
}