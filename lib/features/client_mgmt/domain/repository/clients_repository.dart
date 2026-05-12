import '../../domain/models/client.dart';

abstract class ClientsRepository {
  Future<List<Client>> getClients();
  Future<void> registerClient(Map<String, dynamic> clientData);
  Future<void> deleteClient(String id);
}
