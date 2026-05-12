import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/inspection_repository.dart';
import '../../domain/models/inspection_record.dart';
import 'inspection_event.dart';
import 'inspection_state.dart';

class InspectionBloc extends Bloc<InspectionEvent, InspectionState> {
  final InspectionRepository repository;

  InspectionBloc({required this.repository}) : super(InspectionInitial()) {
    on<FetchInspectionRecords>((event, emit) async {
      emit(InspectionLoading());
      try {
        final records = await repository.getRecords();
        emit(InspectionLoaded(records: records));
      } catch (e) {
        emit(InspectionError(message: e.toString()));
      }
    });

    on<CreateInspectionRecord>((event, emit) async {
      final currentRecords = (state is InspectionLoaded) ? (state as InspectionLoaded).records : 
                             (state is InspectionActionSuccess) ? (state as InspectionActionSuccess).records : <InspectionRecord>[];
      emit(InspectionActionLoading(currentRecords));
      try {
        await repository.createInspection(event.data);
        final updatedRecords = await repository.getRecords();
        emit(InspectionActionSuccess("Inspection scheduled successfully", updatedRecords));
        emit(InspectionLoaded(records: updatedRecords));
      } catch (e) {
        emit(InspectionError(message: e.toString()));
      }
    });

    on<DeleteInspectionRecord>((event, emit) async {
      final currentRecords = (state is InspectionLoaded) ? (state as InspectionLoaded).records : 
                             (state is InspectionActionSuccess) ? (state as InspectionActionSuccess).records : <InspectionRecord>[];
      emit(InspectionActionLoading(currentRecords));
      try {
        await repository.deleteInspection(event.id);
        emit(InspectionActionSuccess("Inspection deleted successfully", currentRecords));
        final updatedRecords = await repository.getRecords();
        emit(InspectionLoaded(records: updatedRecords));
      } catch (e) {
        emit(InspectionError(message: e.toString()));
      }
    });
  }
}
