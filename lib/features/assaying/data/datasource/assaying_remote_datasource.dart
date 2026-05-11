import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/assaying_record.dart';

abstract class AssayingRemoteDataSource {
  Future<List<AssayingRecord>> getRecords();
}

class AssayingRemoteDataSourceImpl implements AssayingRemoteDataSource {
  final Dio dio;

  AssayingRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AssayingRecord>> getRecords() async {
    try {
      final response = await dio.get(ApiConstants.assayingTesting);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => AssayingRecord.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load records");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }
}
