import '../../domain/models/processing_batch.dart';
import '../../domain/repository/processing_repository.dart';
import '../datasource/processing_remote_datasource.dart';

class ProcessingRepositoryImpl implements ProcessingRepository {
  final ProcessingRemoteDataSource remoteDataSource;

  ProcessingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProcessingBatch>> getProcessingBatches() {
    return remoteDataSource.getProcessingBatches();
  }
}
