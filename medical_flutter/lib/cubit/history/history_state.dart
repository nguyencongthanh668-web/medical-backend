import 'package:equatable/equatable.dart';
import 'package:medical_device_tracking/model/equipment_history.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final EquipmentHistory? history;
  final String? message;

  const HistoryState({required this.status, this.history, this.message});

  HistoryState copyWith({HistoryStatus? status, EquipmentHistory? history, String? message}) {
    return HistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, history, message];
}
