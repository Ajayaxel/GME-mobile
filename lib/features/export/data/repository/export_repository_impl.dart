import '../../domain/repository/export_repository.dart';
import '../../domain/models/export_record.dart';
import '../datasource/export_remote_datasource.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportRemoteDataSource remoteDataSource;

  ExportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ExportRecord>> getRecords() async {
    return await remoteDataSource.getRecords();
  }
}
