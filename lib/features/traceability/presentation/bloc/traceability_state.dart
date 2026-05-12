import 'package:equatable/equatable.dart';
import '../../data/models/inventory_log_model.dart';

abstract class TraceabilityState extends Equatable {
  const TraceabilityState();

  @override
  List<Object?> get props => [];
}

class TraceabilityInitial extends TraceabilityState {}

class TraceabilityLoading extends TraceabilityState {}

class TraceabilityLoaded extends TraceabilityState {
  final List<InventoryLogModel> logs;
  const TraceabilityLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class TraceBatchResult extends TraceabilityState {
  final Map<String, dynamic> traceData;
  const TraceBatchResult(this.traceData);

  @override
  List<Object?> get props => [traceData];
}

class TraceabilityError extends TraceabilityState {
  final String message;
  const TraceabilityError(this.message);

  @override
  List<Object?> get props => [message];
}

class TraceabilityActionSuccess extends TraceabilityState {
  final String message;
  const TraceabilityActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
