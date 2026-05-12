import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/inventory_log_model.dart';

abstract class TraceabilityRemoteDataSource {
  Future<List<InventoryLogModel>> getInventoryLogs();
  Future<void> createInventoryLog(Map<String, dynamic> data);
  Future<void> deleteInventoryLog(String id);
  Future<Map<String, dynamic>> traceBatch(String batchId);
}

class TraceabilityRemoteDataSourceImpl implements TraceabilityRemoteDataSource {
  final Dio dio;

  TraceabilityRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<InventoryLogModel>> getInventoryLogs() async {
    try {
      final response = await dio.get(ApiConstants.inventoryLogs);
      return (response.data as List)
          .map((json) => InventoryLogModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  @override
  Future<void> createInventoryLog(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiConstants.inventoryLogs, data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  @override
  Future<void> deleteInventoryLog(String id) async {
    try {
      await dio.delete('${ApiConstants.inventoryLogs}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> traceBatch(String batchId) async {
    try {
      final response = await dio.get('${ApiConstants.inventoryTrace}/$batchId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }
}
