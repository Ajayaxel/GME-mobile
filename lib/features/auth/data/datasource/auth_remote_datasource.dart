import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_models.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return LoginResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
