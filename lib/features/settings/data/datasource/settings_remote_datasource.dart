import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/company_settings.dart';

abstract class SettingsRemoteDataSource {
  Future<CompanySettings> getCompanySettings();
  Future<void> updateCompanySettings(CompanySettings settings);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio dio;

  SettingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<CompanySettings> getCompanySettings() async {
    try {
      final response = await dio.get(ApiConstants.companySettings);
      return CompanySettings.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCompanySettings(CompanySettings settings) async {
    try {
      await dio.patch(
        ApiConstants.companySettings,
        data: settings.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
