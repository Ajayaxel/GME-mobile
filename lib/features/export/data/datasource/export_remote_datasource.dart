import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/export_record.dart';

abstract class ExportRemoteDataSource {
  Future<List<ExportRecord>> getRecords();
  Future<void> createRecord(Map<String, dynamic> data);
  Future<void> uploadDocument(String id, String docKey, String filePath);
  Future<void> deleteDocument(String id, String docKey);
}

class ExportRemoteDataSourceImpl implements ExportRemoteDataSource {
  final Dio dio;

  ExportRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ExportRecord>> getRecords() async {
    try {
      final response = await dio.get(ApiConstants.exportDocumentation);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ExportRecord.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load export documentation");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }

  @override
  Future<void> createRecord(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiConstants.exportDocumentation, data: data);
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to create shipment");
    }
  }

  @override
  Future<void> uploadDocument(String id, String docKey, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      });
      await dio.post("${ApiConstants.exportDocumentation}/upload/$id/$docKey", data: formData);
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to upload document");
    }
  }

  @override
  Future<void> deleteDocument(String id, String docKey) async {
    try {
      await dio.delete("${ApiConstants.exportDocumentation}/document/$id/$docKey");
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to delete document");
    }
  }
}
