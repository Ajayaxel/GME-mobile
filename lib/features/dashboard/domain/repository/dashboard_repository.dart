import '../../domain/models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboardData();
}
