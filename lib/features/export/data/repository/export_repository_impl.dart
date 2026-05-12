import '../../domain/repository/export_repository.dart';
import '../../domain/models/export_record.dart';
import '../datasource/export_remote_datasource.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportRemoteDataSource remoteDataSource;

  ExportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ExportRecord>> getRecords() => remoteDataSource.getRecords();

  @override
  Future<void> createRecord(Map<String, dynamic> data) => remoteDataSource.createRecord(data);

  @override
  Future<void> uploadDocument(String id, String docKey, String filePath) => remoteDataSource.uploadDocument(id, docKey, filePath);

  @override
  Future<void> deleteDocument(String id, String docKey) => remoteDataSource.deleteDocument(id, docKey);
}
