import '../models/weighbridge_record.dart';

abstract class WeighbridgeRepository {
  Future<List<WeighbridgeRecord>> getLogs();
  Future<void> createLog(Map<String, dynamic> data);
}
