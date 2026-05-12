import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:gme/features/bagging/domain/models/bagging_record.dart';

abstract class BaggingRemoteDataSource {
  Future<List<BaggingRecord>> getAllEntries();
  Future<BaggingRecord> createEntry(Map<String, dynamic> entryData);
  Future<void> deleteEntry(String id);
}

class BaggingRemoteDataSourceImpl implements BaggingRemoteDataSource {
  final Dio dio;

  BaggingRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BaggingRecord>> getAllEntries() async {
    try {
      final response = await dio.get(ApiConstants.baggingWarehouse);
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => BaggingRecord.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load bagging entries');
    } catch (e) {
      throw Exception('Error fetching bagging entries: $e');
    }
  }

  @override
  Future<BaggingRecord> createEntry(Map<String, dynamic> entryData) async {
    try {
      final response = await dio.post(ApiConstants.baggingWarehouse, data: entryData);
      if (response.statusCode == 201) {
        return BaggingRecord.fromJson(response.data);
      }
      throw Exception('Failed to create bagging entry');
    } catch (e) {
      throw Exception('Error creating bagging entry: $e');
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.baggingWarehouse}/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete bagging entry');
      }
    } catch (e) {
      throw Exception('Error deleting bagging entry: $e');
    }
  }
}
