import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/client.dart';

abstract class ClientsRemoteDataSource {
  Future<List<Client>> getClients();
}

class ClientsRemoteDataSourceImpl implements ClientsRemoteDataSource {
  final Dio dio;

  ClientsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Client>> getClients() async {
    try {
      final response = await dio.get(ApiConstants.clients);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Client.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load clients");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }
}
