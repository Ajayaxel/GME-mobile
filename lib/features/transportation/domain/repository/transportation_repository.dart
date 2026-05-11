import '../../domain/models/transporter.dart';

abstract class TransportationRepository {
  Future<List<Transporter>> getTransporters();
}
