import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/user_model.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<void> createUser(Map<String, dynamic> userData);
  Future<void> deleteUser(String id);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final Dio dio;

  UsersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await dio.get(ApiConstants.users);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load users");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "An error occurred");
    }
  }

  @override
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post(ApiConstants.users, data: userData);
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception("Failed to create user");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? "An error occurred");
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      final response = await dio.delete("${ApiConstants.users}/$id");
      if (response.statusCode != 200) {
        throw Exception("Failed to delete user");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? "An error occurred");
    }
  }
}
