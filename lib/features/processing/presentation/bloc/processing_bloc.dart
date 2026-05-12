import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/processing_repository.dart';
import 'processing_event.dart';
import 'processing_state.dart';

class ProcessingBloc extends Bloc<ProcessingEvent, ProcessingState> {
  final ProcessingRepository repository;

  ProcessingBloc({required this.repository}) : super(ProcessingInitial()) {
    on<FetchProcessingBatches>(_onFetchProcessingBatches);
    on<CreateProcessingBatch>(_onCreateProcessingBatch);
    on<DeleteProcessingBatch>(_onDeleteProcessingBatch);
  }

  Future<void> _onFetchProcessingBatches(
    FetchProcessingBatches event,
    Emitter<ProcessingState> emit,
  ) async {
    emit(ProcessingLoading());
    try {
      final batches = await repository.getProcessingBatches();
      emit(ProcessingLoaded(batches: batches));
    } catch (e) {
      emit(ProcessingError(message: e.toString()));
    }
  }

  Future<void> _onCreateProcessingBatch(
    CreateProcessingBatch event,
    Emitter<ProcessingState> emit,
  ) async {
    emit(ProcessingActionLoading());
    try {
      await repository.createProcessingBatch(event.batchData);
      emit(const ProcessingActionSuccess("Batch created successfully"));
      add(FetchProcessingBatches());
    } catch (e) {
      emit(ProcessingError(message: e.toString()));
    }
  }

  Future<void> _onDeleteProcessingBatch(
    DeleteProcessingBatch event,
    Emitter<ProcessingState> emit,
  ) async {
    emit(ProcessingActionLoading());
    try {
      await repository.deleteProcessingBatch(event.id);
      emit(const ProcessingActionSuccess("Batch deleted successfully"));
      add(FetchProcessingBatches());
    } catch (e) {
      emit(ProcessingError(message: e.toString()));
    }
  }
}
