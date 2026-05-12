import 'package:equatable/equatable.dart';

abstract class ClientsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchClients extends ClientsEvent {}

class RegisterClient extends ClientsEvent {
  final Map<String, dynamic> clientData;
  RegisterClient({required this.clientData});

  @override
  List<Object?> get props => [clientData];
}

class DeleteClient extends ClientsEvent {
  final String clientId;
  DeleteClient({required this.clientId});

  @override
  List<Object?> get props => [clientId];
}
