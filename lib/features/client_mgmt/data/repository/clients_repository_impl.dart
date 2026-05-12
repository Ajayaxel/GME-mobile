import '../../domain/repository/clients_repository.dart';
import '../../domain/models/client.dart';
import '../datasource/clients_remote_datasource.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  final ClientsRemoteDataSource remoteDataSource;

  ClientsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Client>> getClients() async {
    return await remoteDataSource.getClients();
  }

  @override
  Future<void> registerClient(Map<String, dynamic> clientData) async {
    await remoteDataSource.registerClient(clientData);
  }

  @override
  Future<void> deleteClient(String id) async {
    await remoteDataSource.deleteClient(id);
  }
}
