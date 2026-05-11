import 'package:equatable/equatable.dart';
import '../../domain/models/bagging_record.dart';

abstract class WarehousingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WarehousingInitial extends WarehousingState {}

class WarehousingLoading extends WarehousingState {}

class WarehousingLoaded extends WarehousingState {
  final List<BaggingRecord> records;
  WarehousingLoaded({required this.records});

  @override
  List<Object?> get props => [records];
}

class WarehousingError extends WarehousingState {
  final String message;
  WarehousingError({required this.message});

  @override
  List<Object?> get props => [message];
}
