import 'package:equatable/equatable.dart';
import '../../domain/models/inspection_record.dart';

abstract class InspectionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InspectionInitial extends InspectionState {}

class InspectionLoading extends InspectionState {}

class InspectionLoaded extends InspectionState {
  final List<InspectionRecord> records;
  InspectionLoaded({required this.records});

  @override
  List<Object?> get props => [records];
}

class InspectionError extends InspectionState {
  final String message;
  InspectionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class InspectionActionLoading extends InspectionState {
  final List<InspectionRecord> records;
  InspectionActionLoading(this.records);

  @override
  List<Object?> get props => [records];
}

class InspectionActionSuccess extends InspectionState {
  final String message;
  final List<InspectionRecord> records;
  InspectionActionSuccess(this.message, this.records);

  @override
  List<Object?> get props => [message, records];
}
