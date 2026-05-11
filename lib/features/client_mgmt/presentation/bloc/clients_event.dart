import 'package:equatable/equatable.dart';

abstract class ClientsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchClients extends ClientsEvent {}
