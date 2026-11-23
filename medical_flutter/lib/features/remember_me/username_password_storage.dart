import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UsernamePasswordStorage {
  static Future<void> saveUserNameAndPassword({
    required String username,
    required String password,
  }) async {
    final storage = FlutterSecureStorage();

    await storage.write(key: 'username', value: username);
    await storage.write(key: 'password', value: password);
  }

  static Future<String?> getUserName() async {
    final storage = FlutterSecureStorage();

    return await storage.read(key: 'username');
  }

  static Future<String?> getPassword() async {
    final storage = FlutterSecureStorage();

    return await storage.read(key: 'password');
  }
}