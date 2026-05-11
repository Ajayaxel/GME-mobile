import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(SettingsInitial()) {
    on<LoadSettings>((event, emit) async {
      emit(SettingsLoading());
      try {
        final settings = await repository.getCompanySettings();
        emit(SettingsLoaded(settings));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    });

    on<UpdateSettings>((event, emit) async {
      final currentState = state;
      if (currentState is SettingsLoaded) {
        emit(SettingsUpdating());
        try {
          await repository.updateCompanySettings(event.settings);
          emit(SettingsUpdateSuccess());
          // Reload settings after success
          add(LoadSettings());
        } catch (e) {
          emit(SettingsError(e.toString()));
          // Re-emit loaded state with old settings to allow retry
          emit(SettingsLoaded(currentState.settings));
        }
      }
    });
  }
}
