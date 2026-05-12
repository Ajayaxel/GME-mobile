import '../../data/models/inventory_log_model.dart';

abstract class TraceabilityRepository {
  Future<List<InventoryLogModel>> getInventoryLogs();
  Future<void> createInventoryLog(Map<String, dynamic> data);
  Future<void> deleteInventoryLog(String id);
  Future<Map<String, dynamic>> traceBatch(String batchId);
}
