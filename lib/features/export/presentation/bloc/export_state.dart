import 'package:equatable/equatable.dart';
import '../../domain/models/export_record.dart';

abstract class ExportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExportInitial extends ExportState {}

class ExportLoading extends ExportState {}

class ExportLoaded extends ExportState {
  final List<ExportRecord> records;
  ExportLoaded({required this.records});

  @override
  List<Object?> get props => [records];
}

class ExportError extends ExportState {
  final String message;
  ExportError({required this.message});

  @override
  List<Object?> get props => [message];
}
