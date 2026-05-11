import '../../domain/models/company_settings.dart';

abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final CompanySettings settings;
  UpdateSettings(this.settings);
}
