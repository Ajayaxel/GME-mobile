import 'package:equatable/equatable.dart';

abstract class ProcessingEvent extends Equatable {
  const ProcessingEvent();

  @override
  List<Object?> get props => [];
}

class FetchProcessingBatches extends ProcessingEvent {}

class CreateProcessingBatch extends ProcessingEvent {
  final Map<String, dynamic> batchData;
  const CreateProcessingBatch(this.batchData);

  @override
  List<Object?> get props => [batchData];
}

class DeleteProcessingBatch extends ProcessingEvent {
  final String id;
  const DeleteProcessingBatch(this.id);

  @override
  List<Object?> get props => [id];
}
