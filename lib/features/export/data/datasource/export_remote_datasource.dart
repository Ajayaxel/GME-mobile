import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/export_record.dart';

abstract class ExportRemoteDataSource {
  Future<List<ExportRecord>> getRecords();
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
}
