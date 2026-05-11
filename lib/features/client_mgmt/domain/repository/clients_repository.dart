import '../../domain/models/client.dart';

abstract class ClientsRepository {
  Future<List<Client>> getClients();
}
