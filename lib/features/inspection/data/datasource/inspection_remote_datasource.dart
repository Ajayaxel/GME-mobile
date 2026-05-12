import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/inspection_record.dart';

abstract class InspectionRemoteDataSource {
  Future<List<InspectionRecord>> getRecords();
  Future<void> createInspection(Map<String, dynamic> data);
  Future<void> deleteInspection(String id);
}

class InspectionRemoteDataSourceImpl implements InspectionRemoteDataSource {
  final Dio dio;

  InspectionRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<InspectionRecord>> getRecords() async {
    try {
      final response = await dio.get(ApiConstants.inspectionCertification);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InspectionRecord.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load inspection records");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }

  @override
  Future<void> createInspection(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiConstants.inspectionCertification, data: data);
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred while creating inspection");
    }
  }

  @override
  Future<void> deleteInspection(String id) async {
    try {
      await dio.delete("${ApiConstants.inspectionCertification}/$id");
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred while deleting inspection");
    }
  }
}
