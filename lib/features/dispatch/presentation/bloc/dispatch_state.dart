import 'package:equatable/equatable.dart';
import '../../domain/models/dispatch_record.dart';

abstract class DispatchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DispatchInitial extends DispatchState {}

class DispatchLoading extends DispatchState {}

class DispatchLoaded extends DispatchState {
  final List<DispatchRecord> records;
  DispatchLoaded({required this.records});

  @override
  List<Object?> get props => [records];
}

class DispatchError extends DispatchState {
  final String message;
  DispatchError({required this.message});

  @override
  List<Object?> get props => [message];
}
