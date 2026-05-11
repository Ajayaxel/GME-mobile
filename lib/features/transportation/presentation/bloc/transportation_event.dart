import 'package:equatable/equatable.dart';

abstract class TransportationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTransporters extends TransportationEvent {}
