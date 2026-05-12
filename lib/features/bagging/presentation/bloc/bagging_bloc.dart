import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/bagging_repository.dart';
import '../../domain/models/bagging_record.dart';
import 'bagging_event.dart';
import 'bagging_state.dart';

class BaggingBloc extends Bloc<BaggingEvent, BaggingState> {
  final BaggingRepository repository;

  BaggingBloc({required this.repository}) : super(BaggingInitial()) {
    on<FetchBaggingEntries>(_onFetchBaggingEntries);
    on<CreateBaggingEntry>(_onCreateBaggingEntry);
    on<DeleteBaggingEntry>(_onDeleteBaggingEntry);
  }

  Future<void> _onFetchBaggingEntries(
    FetchBaggingEntries event,
    Emitter<BaggingState> emit,
  ) async {
    emit(BaggingLoading());
    try {
      final records = await repository.getAllEntries();
      emit(BaggingLoaded(records));
    } catch (e) {
      emit(BaggingError(e.toString()));
    }
  }

  Future<void> _onCreateBaggingEntry(
    CreateBaggingEntry event,
    Emitter<BaggingState> emit,
  ) async {
    final currentRecords = (state is BaggingLoaded) 
        ? (state as BaggingLoaded).records 
        : (state is BaggingActionSuccess) 
            ? (state as BaggingActionSuccess).records 
            : <BaggingRecord>[];
            
    emit(BaggingActionLoading(currentRecords));
    try {
      await repository.createEntry(event.entryData);
      final updatedRecords = await repository.getAllEntries();
      emit(BaggingActionSuccess('Bagging record created successfully', updatedRecords));
      emit(BaggingLoaded(updatedRecords));
    } catch (e) {
      emit(BaggingError(e.toString()));
      emit(BaggingLoaded(currentRecords));
    }
  }

  Future<void> _onDeleteBaggingEntry(
    DeleteBaggingEntry event,
    Emitter<BaggingState> emit,
  ) async {
    final currentRecords = (state is BaggingLoaded) 
        ? (state as BaggingLoaded).records 
        : (state is BaggingActionSuccess) 
            ? (state as BaggingActionSuccess).records 
            : <BaggingRecord>[];

    emit(BaggingActionLoading(currentRecords));
    try {
      await repository.deleteEntry(event.id);
      final updatedRecords = await repository.getAllEntries();
      emit(BaggingActionSuccess('Bagging record deleted successfully', updatedRecords));
      emit(BaggingLoaded(updatedRecords));
    } catch (e) {
      emit(BaggingError(e.toString()));
      emit(BaggingLoaded(currentRecords));
    }
  }
}
