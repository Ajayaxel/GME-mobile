import 'package:equatable/equatable.dart';

abstract class FinancialsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchInvoices extends FinancialsEvent {}

class CreateInvoice extends FinancialsEvent {
  final Map<String, dynamic> data;
  CreateInvoice({required this.data});

  @override
  List<Object?> get props => [data];
}
