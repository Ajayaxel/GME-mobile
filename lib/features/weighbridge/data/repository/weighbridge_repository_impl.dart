import '../../domain/models/weighbridge_record.dart';
import '../../domain/repository/weighbridge_repository.dart';
import '../datasource/weighbridge_remote_datasource.dart';

class WeighbridgeRepositoryImpl implements WeighbridgeRepository {
  final WeighbridgeRemoteDataSource remoteDataSource;

  WeighbridgeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<WeighbridgeRecord>> getLogs() {
    return remoteDataSource.getLogs();
  }

  @override
  Future<void> createLog(Map<String, dynamic> data) {
    return remoteDataSource.createLog(data);
  }
}
