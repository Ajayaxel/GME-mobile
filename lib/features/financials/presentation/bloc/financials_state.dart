import 'package:equatable/equatable.dart';
import '../../domain/models/invoice.dart';

abstract class FinancialsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FinancialsInitial extends FinancialsState {}

class FinancialsLoading extends FinancialsState {}

class FinancialsLoaded extends FinancialsState {
  final List<Invoice> invoices;
  FinancialsLoaded({required this.invoices});

  @override
  List<Object?> get props => [invoices];
}

class FinancialsError extends FinancialsState {
  final String message;
  FinancialsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class FinancialsActionSuccess extends FinancialsState {
  final String message;
  FinancialsActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
