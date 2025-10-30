import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
  // Keys for SharedPreferences
  static const String _themeKey = 'theme_is_dark';
  static const String _practiceRemindersKey = 'practice_reminders';

  /// Set the theme mode
  /// 
  /// [isDarkMode] true for dark mode, false for light mode
  Future<void> setThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  /// Get the current theme mode
  /// 
  /// Returns true for dark mode, false for light mode
  /// Default is false (light mode)
  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  /// Set practice reminders setting
  /// 
  /// [enabled] true to enable reminders, false to disable
  Future<void> setPracticeReminders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_practiceRemindersKey, enabled);
  }

  /// Get practice reminders setting
  /// 
  /// Returns true if reminders are enabled, false otherwise
  /// Default is true
  Future<bool> getPracticeReminders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_practiceRemindersKey) ?? true;
  }
}
