import 'package:equatable/equatable.dart';

enum ReportStatus {initial, loading, success, failure}

class ReportDeviceState  extends Equatable {
  final ReportStatus status;
  final String? message;

  const ReportDeviceState({required this.status,
    this.message
  });

  ReportDeviceState copyWith({ReportStatus? status,
    String? message,
  }) {
    return ReportDeviceState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    message,
  ];
}