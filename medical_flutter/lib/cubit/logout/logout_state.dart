import 'package:equatable/equatable.dart';

enum LogoutStatus {initial, loading, success, failure}

class LogoutState extends Equatable {
  final LogoutStatus status;

  const LogoutState({required this.status});

  LogoutState copyWith({LogoutStatus? status}) {
    return LogoutState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}