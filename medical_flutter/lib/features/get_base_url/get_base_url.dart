import 'package:hive_flutter/hive_flutter.dart';

class GetBaseUrl {
  static Future<void> saveBaseUrl({required String baseUrl}) async {
    final box = Hive.box('urlBox');

    await box.put('baseUrl', baseUrl);
  }

  static Future<String> getBaseUrl() async {
    final box = Hive.box('urlBox');

    return box.get('baseUrl');
  }
}