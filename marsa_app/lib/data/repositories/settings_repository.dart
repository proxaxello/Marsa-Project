import 'package:marsa_app/data/providers/settings_provider.dart';

class SettingsRepository {
  final SettingsProvider _settingsProvider;

  SettingsRepository({
    required SettingsProvider settingsProvider,
  }) : _settingsProvider = settingsProvider;

  /// Set the theme mode
  /// 
  /// [isDarkMode] true for dark mode, false for light mode
  Future<void> setThemeMode(bool isDarkMode) async {
    await _settingsProvider.setThemeMode(isDarkMode);
  }

  /// Get the current theme mode
  /// 
  /// Returns true for dark mode, false for light mode
  Future<bool> getThemeMode() async {
    return await _settingsProvider.getThemeMode();
  }

  /// Set practice reminders setting
  /// 
  /// [enabled] true to enable reminders, false to disable
  Future<void> setPracticeReminders(bool enabled) async {
    await _settingsProvider.setPracticeReminders(enabled);
  }

  /// Get practice reminders setting
  /// 
  /// Returns true if reminders are enabled, false otherwise
  Future<bool> getPracticeReminders() async {
    return await _settingsProvider.getPracticeReminders();
  }
}
