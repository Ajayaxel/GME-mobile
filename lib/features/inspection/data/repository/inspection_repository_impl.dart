import '../../domain/repository/inspection_repository.dart';
import '../../domain/models/inspection_record.dart';
import '../datasource/inspection_remote_datasource.dart';

class InspectionRepositoryImpl implements InspectionRepository {
  final InspectionRemoteDataSource remoteDataSource;

  InspectionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<InspectionRecord>> getRecords() async {
    return await remoteDataSource.getRecords();
  }

  @override
  Future<void> createInspection(Map<String, dynamic> data) async {
    await remoteDataSource.createInspection(data);
  }

  @override
  Future<void> deleteInspection(String id) async {
    await remoteDataSource.deleteInspection(id);
  }
}
