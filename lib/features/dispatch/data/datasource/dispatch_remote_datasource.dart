import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/dispatch_record.dart';

abstract class DispatchRemoteDataSource {
  Future<List<DispatchRecord>> getRecords();
  Future<DispatchRecord> createRecord(Map<String, dynamic> record);
  Future<void> deleteRecord(String id);
}

class DispatchRemoteDataSourceImpl implements DispatchRemoteDataSource {
  final Dio dio;

  DispatchRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<DispatchRecord>> getRecords() async {
    try {
      final response = await dio.get(ApiConstants.loadingDispatch);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => DispatchRecord.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load dispatch records");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }

  @override
  Future<DispatchRecord> createRecord(Map<String, dynamic> record) async {
    try {
      final response = await dio.post(ApiConstants.loadingDispatch, data: record);
      if (response.statusCode == 201) {
        return DispatchRecord.fromJson(response.data);
      } else {
        throw Exception("Failed to create dispatch record");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }

  @override
  Future<void> deleteRecord(String id) async {
    try {
      final response = await dio.delete("${ApiConstants.loadingDispatch}/$id");
      if (response.statusCode != 200) {
        throw Exception("Failed to delete dispatch record");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }
}
