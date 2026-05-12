import 'package:equatable/equatable.dart';

abstract class WeighbridgeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchWeighbridgeLogs extends WeighbridgeEvent {}

class CreateWeighbridgeLog extends WeighbridgeEvent {
  final Map<String, dynamic> data;
  CreateWeighbridgeLog({required this.data});

  @override
  List<Object?> get props => [data];
}
