import 'package:equatable/equatable.dart';
import 'package:medical_device_tracking/model/user_data.dart';

enum AllStaffStatus {initial, loading, success, failure}

class AllStaffState extends Equatable {
  final AllStaffStatus status;
  final List<UserData>? listUser;
  final String? message;

  const AllStaffState({required this.status,
    this.listUser,
    this.message,
  });

  AllStaffState copyWith({AllStaffStatus? status,
    List<UserData>? listUser,
    String? message,
  }) {
    return AllStaffState(
      status: status ?? this.status,
      listUser: listUser ?? this.listUser,
      message:  message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    listUser,
    message,
  ];
}