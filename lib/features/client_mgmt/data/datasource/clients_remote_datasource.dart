import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/client.dart';

abstract class ClientsRemoteDataSource {
  Future<List<Client>> getClients();
  Future<void> registerClient(Map<String, dynamic> clientData);
  Future<void> deleteClient(String id);
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

  @override
  Future<void> registerClient(Map<String, dynamic> clientData) async {
    try {
      final response = await dio.post(ApiConstants.clients, data: clientData);
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception("Failed to register client");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? "An error occurred");
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      final response = await dio.delete("${ApiConstants.clients}/$id");
      if (response.statusCode != 200) {
        throw Exception("Failed to delete client");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? "An error occurred");
    }
  }
}
