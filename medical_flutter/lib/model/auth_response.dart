import 'package:medical_device_tracking/model/user_data.dart';

class AuthResponse {
  final UserData data;
  final int statusCode;
  final String accessToken;
  final String tokenType;

  AuthResponse({
    required this.data,
    required this.statusCode,
    required this.accessToken,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      data: UserData.fromJson(json['data']),
      statusCode: json['status_code'],
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'status_code': statusCode,
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }
}
