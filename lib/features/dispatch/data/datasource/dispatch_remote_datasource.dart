import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/dispatch_record.dart';

abstract class DispatchRemoteDataSource {
  Future<List<DispatchRecord>> getRecords();
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
}
