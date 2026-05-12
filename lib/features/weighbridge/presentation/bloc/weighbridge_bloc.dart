import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/weighbridge_repository.dart';
import 'weighbridge_event.dart';
import 'weighbridge_state.dart';

class WeighbridgeBloc extends Bloc<WeighbridgeEvent, WeighbridgeState> {
  final WeighbridgeRepository repository;

  WeighbridgeBloc({required this.repository}) : super(WeighbridgeInitial()) {
    on<FetchWeighbridgeLogs>(_onFetchLogs);
    on<CreateWeighbridgeLog>(_onCreateLog);
  }

  Future<void> _onFetchLogs(FetchWeighbridgeLogs event, Emitter<WeighbridgeState> emit) async {
    emit(WeighbridgeLoading());
    try {
      final logs = await repository.getLogs();
      emit(WeighbridgeLoaded(logs: logs));
    } catch (e) {
      emit(WeighbridgeError(message: e.toString()));
    }
  }

  Future<void> _onCreateLog(CreateWeighbridgeLog event, Emitter<WeighbridgeState> emit) async {
    try {
      await repository.createLog(event.data);
      add(FetchWeighbridgeLogs());
    } catch (e) {
      emit(WeighbridgeError(message: e.toString()));
    }
  }
}
