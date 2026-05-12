import 'package:equatable/equatable.dart';
import '../../domain/models/weighbridge_record.dart';

abstract class WeighbridgeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WeighbridgeInitial extends WeighbridgeState {}

class WeighbridgeLoading extends WeighbridgeState {}

class WeighbridgeLoaded extends WeighbridgeState {
  final List<WeighbridgeRecord> logs;
  WeighbridgeLoaded({required this.logs});

  @override
  List<Object?> get props => [logs];
}

class WeighbridgeError extends WeighbridgeState {
  final String message;
  WeighbridgeError({required this.message});

  @override
  List<Object?> get props => [message];
}
