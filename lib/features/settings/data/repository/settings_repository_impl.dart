import '../../domain/models/company_settings.dart';
import '../../domain/repository/settings_repository.dart';
import '../datasource/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CompanySettings> getCompanySettings() {
    return remoteDataSource.getCompanySettings();
  }

  @override
  Future<void> updateCompanySettings(CompanySettings settings) {
    return remoteDataSource.updateCompanySettings(settings);
  }
}
