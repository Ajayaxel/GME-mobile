import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/clients_repository.dart';
import 'clients_event.dart';
import 'clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  final ClientsRepository repository;

  ClientsBloc({required this.repository}) : super(ClientsInitial()) {
    on<FetchClients>((event, emit) async {
      emit(ClientsLoading());
      try {
        final clients = await repository.getClients();
        emit(ClientsLoaded(clients: clients));
      } catch (e) {
        emit(ClientsError(message: e.toString()));
      }
    });
  }
}
