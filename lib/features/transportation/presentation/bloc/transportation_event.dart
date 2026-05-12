import 'package:equatable/equatable.dart';

abstract class TransportationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTransporters extends TransportationEvent {}

class CreateTransporter extends TransportationEvent {
  final Map<String, dynamic> data;
  CreateTransporter({required this.data});

  @override
  List<Object?> get props => [data];
}

class CreateTrip extends TransportationEvent {
  final Map<String, dynamic> data;
  CreateTrip({required this.data});

  @override
  List<Object?> get props => [data];
}
