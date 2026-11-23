import 'package:hive_flutter/hive_flutter.dart';

class UserInfoStorage {
  static Future<void> saveUserInfo({required int id,
    required String displayname,
    required String email,
    required String phone,
    required String birthday,
    required String gender,
    required String profilePhotoUrl,
    String role = '',
    int? departmentId,
  }) async {
    final box = Hive.box('authBox');

    await box.put('id', id);
    await box.put('displayname', displayname);
    await box.put('email', email);
    await box.put('phone', phone);
    await box.put('birthday', birthday);
    await box.put('gender', gender);
    await box.put('profilePhotoUrl', profilePhotoUrl);
    await box.put('role', role);
    await box.put('departmentId', departmentId);
  }

  static Future<String> getProfilePhotoUrl() async {
    final box = Hive.box('authBox');

    return box.get('profilePhotoUrl');
  }

  static Future<int> getUserId() async {
    final box = Hive.box('authBox');

    return box.get('id');
  }

  /// Vai trò do máy chủ trả về khi đăng nhập (department, technician, manager, admin).
  static String getRole() {
    final box = Hive.box('authBox');

    return (box.get('role') as String?) ?? '';
  }

  static int? getDepartmentId() {
    final box = Hive.box('authBox');

    return box.get('departmentId') as int?;
  }
}
