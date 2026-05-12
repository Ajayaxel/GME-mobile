import '../../domain/models/bagging_record.dart';
import '../../domain/repository/bagging_repository.dart';
import '../datasource/bagging_remote_datasource.dart';

class BaggingRepositoryImpl implements BaggingRepository {
  final BaggingRemoteDataSource remoteDataSource;

  BaggingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BaggingRecord>> getAllEntries() {
    return remoteDataSource.getAllEntries();
  }

  @override
  Future<BaggingRecord> createEntry(Map<String, dynamic> entryData) {
    return remoteDataSource.createEntry(entryData);
  }

  @override
  Future<void> deleteEntry(String id) {
    return remoteDataSource.deleteEntry(id);
  }
}
