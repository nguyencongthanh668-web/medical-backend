import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/history/history_state.dart';
import 'package:medical_device_tracking/features/workflow/workflow_api.dart';

/// Tải lịch sử thật của thiết bị cho Timeline (FR-05, UC-05).
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryState(status: HistoryStatus.initial));

  Future<void> load(int equipmentId) async {
    emit(const HistoryState(status: HistoryStatus.loading));
    try {
      final history = await WorkflowApi.getHistory(equipmentId);
      emit(HistoryState(status: HistoryStatus.success, history: history));
    } on ApiException catch (e) {
      emit(HistoryState(status: HistoryStatus.failure, message: e.message));
    }
  }
}
