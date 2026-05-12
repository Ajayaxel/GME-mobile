import 'package:equatable/equatable.dart';

abstract class ExportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchExportRecords extends ExportEvent {}

class CreateExportRecord extends ExportEvent {
  final Map<String, dynamic> record;
  CreateExportRecord({required this.record});
}

class UploadExportDocument extends ExportEvent {
  final String id;
  final String docKey;
  final String filePath;
  UploadExportDocument({required this.id, required this.docKey, required this.filePath});
}

class DeleteExportDocument extends ExportEvent {
  final String id;
  final String docKey;
  DeleteExportDocument({required this.id, required this.docKey});
}
