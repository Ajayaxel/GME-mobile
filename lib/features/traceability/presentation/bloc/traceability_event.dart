import 'package:equatable/equatable.dart';

abstract class TraceabilityEvent extends Equatable {
  const TraceabilityEvent();

  @override
  List<Object?> get props => [];
}

class FetchInventoryLogs extends TraceabilityEvent {}

class CreateInventoryLog extends TraceabilityEvent {
  final Map<String, dynamic> data;
  const CreateInventoryLog(this.data);

  @override
  List<Object?> get props => [data];
}

class DeleteInventoryLog extends TraceabilityEvent {
  final String id;
  const DeleteInventoryLog(this.id);

  @override
  List<Object?> get props => [id];
}

class TraceBatch extends TraceabilityEvent {
  final String batchId;
  const TraceBatch(this.batchId);

  @override
  List<Object?> get props => [batchId];
}
