import '../../domain/repository/dispatch_repository.dart';
import '../../domain/models/dispatch_record.dart';
import '../datasource/dispatch_remote_datasource.dart';

class DispatchRepositoryImpl implements DispatchRepository {
  final DispatchRemoteDataSource remoteDataSource;

  DispatchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DispatchRecord>> getRecords() async {
    return await remoteDataSource.getRecords();
  }

  @override
  Future<DispatchRecord> createRecord(Map<String, dynamic> record) async {
    return await remoteDataSource.createRecord(record);
  }

  @override
  Future<void> deleteRecord(String id) async {
    return await remoteDataSource.deleteRecord(id);
  }
}
