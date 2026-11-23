import 'package:equatable/equatable.dart';
import 'package:medical_device_tracking/model/user_data.dart';

enum ProfileStatus {initial, loading, success, failure}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserData? userInfo;
  final String? message;

  const ProfileState({required this.status,
    this.userInfo,
    this.message,
  });

  ProfileState copyWith({ProfileStatus? status,
    UserData? userInfo,
    String? message,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userInfo: userInfo ?? this.userInfo,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userInfo,
    message,
  ];
}