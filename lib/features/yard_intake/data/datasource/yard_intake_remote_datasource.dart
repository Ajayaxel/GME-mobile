import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/yard_intake_model.dart';

abstract class YardIntakeRemoteDataSource {
  Future<List<YardIntakeModel>> getYardIntake();
  Future<void> deleteYardIntake(String id);
  Future<void> updateYardIntake(String id, Map<String, dynamic> data);
  Future<void> createYardIntake(Map<String, dynamic> data);
}

class YardIntakeRemoteDataSourceImpl implements YardIntakeRemoteDataSource {
  final Dio dio;

  YardIntakeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<YardIntakeModel>> getYardIntake() async {
    try {
      final response = await dio.get(ApiConstants.yardIntake);
      return (response.data as List)
          .map((e) => YardIntakeModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteYardIntake(String id) async {
    try {
      await dio.delete("${ApiConstants.yardIntake}/$id");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateYardIntake(String id, Map<String, dynamic> data) async {
    try {
      await dio.patch("${ApiConstants.yardIntake}/$id", data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createYardIntake(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiConstants.yardIntake, data: data);
    } catch (e) {
      rethrow;
    }
  }
}
