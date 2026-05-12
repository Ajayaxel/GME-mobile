import '../../domain/models/dashboard_model.dart';
import '../../domain/repository/dashboard_repository.dart';
import '../datasource/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardData> getDashboardData() async {
    return await remoteDataSource.getDashboardData();
  }
}
