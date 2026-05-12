import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/dispatch_repository.dart';
import 'dispatch_event.dart';
import 'dispatch_state.dart';

class DispatchBloc extends Bloc<DispatchEvent, DispatchState> {
  final DispatchRepository repository;

  DispatchBloc({required this.repository}) : super(DispatchInitial()) {
    on<FetchDispatchRecords>((event, emit) async {
      emit(DispatchLoading());
      try {
        final records = await repository.getRecords();
        emit(DispatchLoaded(records: records));
      } catch (e) {
        emit(DispatchError(message: e.toString()));
      }
    });

    on<CreateDispatchRecord>((event, emit) async {
      // Keep previous state to show loading or just show a global loading
      try {
        await repository.createRecord(event.record);
        add(FetchDispatchRecords()); // Refresh list
      } catch (e) {
        emit(DispatchError(message: e.toString()));
      }
    });

    on<DeleteDispatchRecord>((event, emit) async {
      try {
        await repository.deleteRecord(event.id);
        add(FetchDispatchRecords()); // Refresh list
      } catch (e) {
        emit(DispatchError(message: e.toString()));
      }
    });
  }
}
