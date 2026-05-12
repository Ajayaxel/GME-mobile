import 'package:equatable/equatable.dart';
import '../../domain/models/transporter.dart';

abstract class TransportationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransportationInitial extends TransportationState {}

class TransportationLoading extends TransportationState {}

class TransportationLoaded extends TransportationState {
  final List<Transporter> transporters;
  TransportationLoaded({required this.transporters});

  @override
  List<Object?> get props => [transporters];
}

class TransportationError extends TransportationState {
  final String message;
  TransportationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransportationActionSuccess extends TransportationState {
  final String message;
  TransportationActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
