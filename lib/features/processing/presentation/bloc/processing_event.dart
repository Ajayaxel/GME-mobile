import 'package:equatable/equatable.dart';

abstract class ProcessingEvent extends Equatable {
  const ProcessingEvent();

  @override
  List<Object?> get props => [];
}

class FetchProcessingBatches extends ProcessingEvent {}
