import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/traceability_repository.dart';
import 'traceability_event.dart';
import 'traceability_state.dart';

class TraceabilityBloc extends Bloc<TraceabilityEvent, TraceabilityState> {
  final TraceabilityRepository repository;

  TraceabilityBloc({required this.repository}) : super(TraceabilityInitial()) {
    on<FetchInventoryLogs>((event, emit) async {
      emit(TraceabilityLoading());
      try {
        final logs = await repository.getInventoryLogs();
        emit(TraceabilityLoaded(logs));
      } catch (e) {
        emit(TraceabilityError(e.toString()));
      }
    });

    on<CreateInventoryLog>((event, emit) async {
      emit(TraceabilityLoading());
      try {
        await repository.createInventoryLog(event.data);
        emit(const TraceabilityActionSuccess("Inventory log created successfully"));
        add(FetchInventoryLogs());
      } catch (e) {
        emit(TraceabilityError(e.toString()));
      }
    });

    on<DeleteInventoryLog>((event, emit) async {
      emit(TraceabilityLoading());
      try {
        await repository.deleteInventoryLog(event.id);
        emit(const TraceabilityActionSuccess("Inventory log deleted successfully"));
        add(FetchInventoryLogs());
      } catch (e) {
        emit(TraceabilityError(e.toString()));
      }
    });

    on<TraceBatch>((event, emit) async {
      emit(TraceabilityLoading());
      try {
        final traceData = await repository.traceBatch(event.batchId);
        emit(TraceBatchResult(traceData));
      } catch (e) {
        emit(TraceabilityError(e.toString()));
      }
    });
  }
}
