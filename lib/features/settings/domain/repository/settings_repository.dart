import '../models/company_settings.dart';

abstract class SettingsRepository {
  Future<CompanySettings> getCompanySettings();
  Future<void> updateCompanySettings(CompanySettings settings);
}
