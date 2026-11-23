import 'package:equatable/equatable.dart';
import 'package:medical_device_tracking/model/department.dart';

enum AllDepartmentStatus {initial, loading, success, failure}

class AllDepartmentState extends Equatable {
  final AllDepartmentStatus status;
  final List<DepartmentModel>? listDepartment;
  final String? message;

  const AllDepartmentState({required this.status,
    this.listDepartment,
    this.message,
  });

  AllDepartmentState copyWith({AllDepartmentStatus? status,
    List<DepartmentModel>? listDepartment,
    String? message,
  }) {
    return AllDepartmentState(
      status: status ?? this.status,
      listDepartment: listDepartment ?? this.listDepartment,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    listDepartment,
    message,
  ];
}