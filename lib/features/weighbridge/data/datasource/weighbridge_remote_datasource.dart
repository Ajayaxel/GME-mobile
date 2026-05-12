import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/weighbridge_record.dart';

abstract class WeighbridgeRemoteDataSource {
  Future<List<WeighbridgeRecord>> getLogs();
  Future<void> createLog(Map<String, dynamic> data);
}

class WeighbridgeRemoteDataSourceImpl implements WeighbridgeRemoteDataSource {
  final Dio dio;

  WeighbridgeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<WeighbridgeRecord>> getLogs() async {
    try {
      final response = await dio.get(ApiConstants.weighbridge);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => WeighbridgeRecord.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load weighbridge logs");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }

  @override
  Future<void> createLog(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiConstants.weighbridge, data: data);
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to create weighbridge log");
    }
  }
}
