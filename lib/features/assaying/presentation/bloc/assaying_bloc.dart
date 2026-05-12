import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/assaying_repository.dart';
import '../../domain/models/assaying_record.dart';
import 'assaying_event.dart';
import 'assaying_state.dart';

class AssayingBloc extends Bloc<AssayingEvent, AssayingState> {
  final AssayingRepository repository;

  AssayingBloc({required this.repository}) : super(AssayingInitial()) {
    on<FetchAssayingRecords>((event, emit) async {
      emit(AssayingLoading());
      try {
        final records = await repository.getRecords();
        emit(AssayingLoaded(records: records));
      } catch (e) {
        emit(AssayingError(message: e.toString()));
      }
    });

    on<CreateAssayingRecord>((event, emit) async {
      final currentRecords = (state is AssayingLoaded) ? (state as AssayingLoaded).records : <AssayingRecord>[];
      emit(AssayingActionLoading(currentRecords));
      try {
        await repository.createSample(event.data);
        final updatedRecords = await repository.getRecords();
        emit(AssayingActionSuccess("Sample submitted successfully", updatedRecords));
        emit(AssayingLoaded(records: updatedRecords));
      } catch (e) {
        emit(AssayingError(message: e.toString()));
      }
    });

    on<DeleteAssayingRecord>((event, emit) async {
      final currentRecords = (state is AssayingLoaded) ? (state as AssayingLoaded).records : 
                             (state is AssayingActionSuccess) ? (state as AssayingActionSuccess).records : <AssayingRecord>[];
      emit(AssayingActionLoading(currentRecords));
      try {
        await repository.deleteSample(event.id);
        emit(AssayingActionSuccess("Sample deleted successfully", currentRecords));
        final updatedRecords = await repository.getRecords();
        emit(AssayingLoaded(records: updatedRecords));
      } catch (e) {
        emit(AssayingError(message: e.toString()));
      }
    });
  }
}
