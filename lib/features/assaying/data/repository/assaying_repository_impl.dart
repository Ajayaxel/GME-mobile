import '../../domain/repository/assaying_repository.dart';
import '../../domain/models/assaying_record.dart';
import '../datasource/assaying_remote_datasource.dart';

class AssayingRepositoryImpl implements AssayingRepository {
  final AssayingRemoteDataSource remoteDataSource;

  AssayingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AssayingRecord>> getRecords() async {
    return await remoteDataSource.getRecords();
  }
}
