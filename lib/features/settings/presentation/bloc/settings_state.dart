import '../../domain/models/company_settings.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final CompanySettings settings;
  SettingsLoaded(this.settings);
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}

class SettingsUpdating extends SettingsState {}

class SettingsUpdateSuccess extends SettingsState {}
