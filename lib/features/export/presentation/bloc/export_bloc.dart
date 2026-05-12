import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/export_repository.dart';
import 'export_event.dart';
import 'export_state.dart';

class ExportBloc extends Bloc<ExportEvent, ExportState> {
  final ExportRepository repository;

  ExportBloc({required this.repository}) : super(ExportInitial()) {
    on<FetchExportRecords>(_onFetchExportRecords);
    on<CreateExportRecord>(_onCreateExportRecord);
    on<UploadExportDocument>(_onUploadExportDocument);
    on<DeleteExportDocument>(_onDeleteExportDocument);
  }

  Future<void> _onFetchExportRecords(FetchExportRecords event, Emitter<ExportState> emit) async {
    emit(ExportLoading());
    try {
      final records = await repository.getRecords();
      emit(ExportLoaded(records: records));
    } catch (e) {
      emit(ExportError(message: e.toString()));
    }
  }

  Future<void> _onCreateExportRecord(CreateExportRecord event, Emitter<ExportState> emit) async {
    try {
      await repository.createRecord(event.record);
      emit(ExportActionSuccess(message: "Shipment initialized successfully!"));
      add(FetchExportRecords());
    } catch (e) {
      emit(ExportError(message: e.toString()));
    }
  }

  Future<void> _onUploadExportDocument(UploadExportDocument event, Emitter<ExportState> emit) async {
    try {
      await repository.uploadDocument(event.id, event.docKey, event.filePath);
      emit(ExportActionSuccess(message: "Document uploaded successfully!"));
      add(FetchExportRecords());
    } catch (e) {
      emit(ExportError(message: e.toString()));
    }
  }

  Future<void> _onDeleteExportDocument(DeleteExportDocument event, Emitter<ExportState> emit) async {
    try {
      await repository.deleteDocument(event.id, event.docKey);
      emit(ExportActionSuccess(message: "Document deleted successfully!"));
      add(FetchExportRecords());
    } catch (e) {
      emit(ExportError(message: e.toString()));
    }
  }
}
