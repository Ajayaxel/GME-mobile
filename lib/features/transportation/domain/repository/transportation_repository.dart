import '../../domain/models/transporter.dart';

abstract class TransportationRepository {
  Future<List<Transporter>> getTransporters();
  Future<void> createTransporter(Map<String, dynamic> data);
  Future<void> createTrip(Map<String, dynamic> data);
}
