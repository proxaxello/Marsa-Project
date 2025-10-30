import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

/// Event to load settings from storage
class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Event to toggle theme mode
class ToggleThemeMode extends SettingsEvent {
  final bool isDarkMode;

  const ToggleThemeMode(this.isDarkMode);

  @override
  List<Object> get props => [isDarkMode];
}

/// Event to toggle practice reminders
class TogglePracticeReminders extends SettingsEvent {
  final bool enabled;

  const TogglePracticeReminders(this.enabled);

  @override
  List<Object> get props => [enabled];
}
