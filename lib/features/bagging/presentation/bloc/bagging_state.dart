import 'package:equatable/equatable.dart';
import '../../domain/models/bagging_record.dart';

abstract class BaggingState extends Equatable {
  const BaggingState();

  @override
  List<Object?> get props => [];
}

class BaggingInitial extends BaggingState {}

class BaggingLoading extends BaggingState {}

class BaggingLoaded extends BaggingState {
  final List<BaggingRecord> records;
  const BaggingLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class BaggingError extends BaggingState {
  final String message;
  const BaggingError(this.message);

  @override
  List<Object?> get props => [message];
}

class BaggingActionLoading extends BaggingState {
  final List<BaggingRecord> records;
  const BaggingActionLoading(this.records);

  @override
  List<Object?> get props => [records];
}

class BaggingActionSuccess extends BaggingState {
  final String message;
  final List<BaggingRecord> records;
  const BaggingActionSuccess(this.message, this.records);

  @override
  List<Object?> get props => [message, records];
}
