import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/assaying_repository.dart';
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
  }
}
