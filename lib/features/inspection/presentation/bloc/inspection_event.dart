import 'package:equatable/equatable.dart';

abstract class InspectionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchInspectionRecords extends InspectionEvent {}

class CreateInspectionRecord extends InspectionEvent {
  final Map<String, dynamic> data;
  CreateInspectionRecord(this.data);

  @override
  List<Object?> get props => [data];
}

class DeleteInspectionRecord extends InspectionEvent {
  final String id;
  DeleteInspectionRecord(this.id);

  @override
  List<Object?> get props => [id];
}
