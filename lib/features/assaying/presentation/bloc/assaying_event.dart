import 'package:equatable/equatable.dart';

abstract class AssayingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAssayingRecords extends AssayingEvent {}

class CreateAssayingRecord extends AssayingEvent {
  final Map<String, dynamic> data;
  CreateAssayingRecord(this.data);

  @override
  List<Object?> get props => [data];
}

class DeleteAssayingRecord extends AssayingEvent {
  final String id;
  DeleteAssayingRecord(this.id);

  @override
  List<Object?> get props => [id];
}
