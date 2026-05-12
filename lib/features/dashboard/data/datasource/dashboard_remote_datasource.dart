import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardData> getDashboardData();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<DashboardData> getDashboardData() async {
    try {
      final response = await dio.get(ApiConstants.dashboardStats);
      if (response.statusCode == 200) {
        return DashboardData.fromJson(response.data);
      } else {
        throw Exception("Failed to load dashboard data");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }
}
