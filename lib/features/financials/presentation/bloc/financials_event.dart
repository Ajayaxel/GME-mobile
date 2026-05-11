import 'package:equatable/equatable.dart';

abstract class FinancialsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchInvoices extends FinancialsEvent {}
