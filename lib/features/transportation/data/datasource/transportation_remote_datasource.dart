import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/transporter.dart';

abstract class TransportationRemoteDataSource {
  Future<List<Transporter>> getTransporters();
  Future<void> createTransporter(Map<String, dynamic> data);
  Future<void> createTrip(Map<String, dynamic> data);
}

class TransportationRemoteDataSourceImpl implements TransportationRemoteDataSource {
  final Dio dio;

  TransportationRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Transporter>> getTransporters() async {
    try {
      final response = await dio.get(ApiConstants.transporters);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Transporter.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load transporters");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }

  @override
  Future<void> createTransporter(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiConstants.transporters, data: data);
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to create transporter");
    }
  }

  @override
  Future<void> createTrip(Map<String, dynamic> data) async {
    try {
      await dio.post(ApiConstants.trips, data: data);
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to assign trip");
    }
  }
}
