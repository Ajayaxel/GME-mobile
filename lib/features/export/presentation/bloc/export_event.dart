import 'package:equatable/equatable.dart';

abstract class ExportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchExportRecords extends ExportEvent {}
