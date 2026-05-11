import 'package:dio/dio.dart';
import 'package:gme/core/constants/api_constants.dart';
import '../../domain/models/processing_batch.dart';

abstract class ProcessingRemoteDataSource {
  Future<List<ProcessingBatch>> getProcessingBatches();
}

class ProcessingRemoteDataSourceImpl implements ProcessingRemoteDataSource {
  final Dio dio;

  ProcessingRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProcessingBatch>> getProcessingBatches() async {
    try {
      final response = await dio.get(ApiConstants.crushingProcessing);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProcessingBatch.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load processing batches");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
 
    }
  }
}
