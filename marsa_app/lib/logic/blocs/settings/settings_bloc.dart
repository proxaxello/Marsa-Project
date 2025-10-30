import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/data/repositories/settings_repository.dart';
import 'package:marsa_app/logic/blocs/settings/settings_event.dart';
import 'package:marsa_app/logic/blocs/settings/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;
  
  SettingsBloc({
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository,
       super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleThemeMode>(_onToggleThemeMode);
    on<TogglePracticeReminders>(_onTogglePracticeReminders);
    
    // Load settings when bloc is created
    add(const LoadSettings());
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    // Get settings from repository
    final isDarkMode = await _settingsRepository.getThemeMode();
    final practiceRemindersEnabled = await _settingsRepository.getPracticeReminders();
    
    // Emit loaded state with settings
    emit(SettingsLoaded(
      isDarkMode: isDarkMode,
      practiceRemindersEnabled: practiceRemindersEnabled,
    ));
  }

  void _onToggleThemeMode(ToggleThemeMode event, Emitter<SettingsState> emit) async {
    // Save new theme mode setting
    await _settingsRepository.setThemeMode(event.isDarkMode);
    
    // Get current state
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      
      // Emit new state with updated theme mode
      emit(currentState.copyWith(isDarkMode: event.isDarkMode));
    }
  }

  void _onTogglePracticeReminders(TogglePracticeReminders event, Emitter<SettingsState> emit) async {
    // Save new practice reminders setting
    await _settingsRepository.setPracticeReminders(event.enabled);
    
    // Get current state
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      
      // Emit new state with updated practice reminders setting
      emit(currentState.copyWith(practiceRemindersEnabled: event.enabled));
    }
  }
}
