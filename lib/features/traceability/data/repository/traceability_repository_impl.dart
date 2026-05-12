import '../../domain/repository/traceability_repository.dart';
import '../datasource/traceability_remote_datasource.dart';
import '../models/inventory_log_model.dart';

class TraceabilityRepositoryImpl implements TraceabilityRepository {
  final TraceabilityRemoteDataSource remoteDataSource;

  TraceabilityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<InventoryLogModel>> getInventoryLogs() {
    return remoteDataSource.getInventoryLogs();
  }

  @override
  Future<void> createInventoryLog(Map<String, dynamic> data) {
    return remoteDataSource.createInventoryLog(data);
  }

  @override
  Future<void> deleteInventoryLog(String id) {
    return remoteDataSource.deleteInventoryLog(id);
  }

  @override
  Future<Map<String, dynamic>> traceBatch(String batchId) {
    return remoteDataSource.traceBatch(batchId);
  }
}
