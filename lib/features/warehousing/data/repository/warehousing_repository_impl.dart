import '../../domain/repository/warehousing_repository.dart';
import '../../domain/models/bagging_record.dart';
import '../datasource/warehousing_remote_datasource.dart';

class WarehousingRepositoryImpl implements WarehousingRepository {
  final WarehousingRemoteDataSource remoteDataSource;

  WarehousingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BaggingRecord>> getRecords() async {
    return await remoteDataSource.getRecords();
  }
}
