import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/export_repository.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ExportRepository repository;

  ExportBloc({required this.repository}) : super(ExportInitial()) {
    on<FetchExportRecords>((event, emit) async {
      emit(ExportLoading());
      try {
        final records = await repository.getRecords();
        emit(ExportLoaded(records: records));
      } catch (e) {
        emit(ExportError(message: e.toString()));
      }
    });
  }
}
