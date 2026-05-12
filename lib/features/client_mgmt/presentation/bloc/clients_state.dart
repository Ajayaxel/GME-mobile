import 'package:equatable/equatable.dart';
import '../../domain/models/client.dart';

abstract class ClientsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClientsInitial extends ClientsState {}

class ClientsLoading extends ClientsState {}

class ClientsLoaded extends ClientsState {
  final List<Client> clients;
  ClientsLoaded({required this.clients});

  @override
  List<Object?> get props => [clients];
}

class ClientsError extends ClientsState {
  final String message;
  ClientsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ClientRegistered extends ClientsState {}

class ClientDeleted extends ClientsState {}
