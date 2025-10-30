import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  
  @override
  List<Object> get props => [];
}

/// Initial state before settings are loaded
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// State when settings are loaded
class SettingsLoaded extends SettingsState {
  final bool isDarkMode;
  final bool practiceRemindersEnabled;
  
  const SettingsLoaded({
    required this.isDarkMode,
    required this.practiceRemindersEnabled,
  });
  
  @override
  List<Object> get props => [isDarkMode, practiceRemindersEnabled];
  
  /// Create a copy of this SettingsLoaded with the given fields replaced
  SettingsLoaded copyWith({
    bool? isDarkMode,
    bool? practiceRemindersEnabled,
  }) {
    return SettingsLoaded(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      practiceRemindersEnabled: practiceRemindersEnabled ?? this.practiceRemindersEnabled,
    );
  }
}
