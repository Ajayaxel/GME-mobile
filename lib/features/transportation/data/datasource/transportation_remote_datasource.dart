import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/transporter.dart';

abstract class TransportationRemoteDataSource {
  Future<List<Transporter>> getTransporters();
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
}
