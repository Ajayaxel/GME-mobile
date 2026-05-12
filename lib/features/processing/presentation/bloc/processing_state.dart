import 'package:equatable/equatable.dart';
import '../../domain/models/processing_batch.dart';

abstract class ProcessingState extends Equatable {
  const ProcessingState();

  @override
  List<Object?> get props => [];
}

class ProcessingInitial extends ProcessingState {}

class ProcessingLoading extends ProcessingState {}

class ProcessingLoaded extends ProcessingState {
  final List<ProcessingBatch> batches;

  const ProcessingLoaded({required this.batches});

  @override
  List<Object?> get props => [batches];
}

class ProcessingError extends ProcessingState {
  final String message;

  const ProcessingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProcessingActionSuccess extends ProcessingState {
  final String message;
  const ProcessingActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProcessingActionLoading extends ProcessingState {}
