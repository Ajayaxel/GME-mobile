import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/bagging_record.dart';

abstract class WarehousingRemoteDataSource {
  Future<List<BaggingRecord>> getRecords();
}

class WarehousingRemoteDataSourceImpl implements WarehousingRemoteDataSource {
  final Dio dio;

  WarehousingRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BaggingRecord>> getRecords() async {
    try {
      final response = await dio.get(ApiConstants.baggingWarehouse);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BaggingRecord.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load warehousing records");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }
}
