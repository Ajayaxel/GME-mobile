import 'package:equatable/equatable.dart';
import '../../domain/models/assaying_record.dart';

abstract class AssayingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AssayingInitial extends AssayingState {}

class AssayingLoading extends AssayingState {}

class AssayingLoaded extends AssayingState {
  final List<AssayingRecord> records;
  AssayingLoaded({required this.records});

  @override
  List<Object?> get props => [records];
}

class AssayingError extends AssayingState {
  final String message;
  AssayingError({required this.message});

  @override
  List<Object?> get props => [message];
}
