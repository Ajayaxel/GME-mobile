import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/processing_repository.dart';
import 'processing_event.dart';
import 'processing_state.dart';

class ProcessingBloc extends Bloc<ProcessingEvent, ProcessingState> {
  final ProcessingRepository repository;

  ProcessingBloc({required this.repository}) : super(ProcessingInitial()) {
    on<FetchProcessingBatches>((event, emit) async {
      emit(ProcessingLoading());
      try {
        final batches = await repository.getProcessingBatches();
        emit(ProcessingLoaded(batches: batches));
      } catch (e) {
        emit(ProcessingError(message: e.toString()));
      }
    });
  }
}
