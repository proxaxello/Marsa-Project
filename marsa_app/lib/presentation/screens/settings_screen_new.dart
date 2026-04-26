import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marsa_app/logic/blocs/settings/settings_bloc.dart';
import 'package:marsa_app/logic/blocs/settings/settings_event.dart';
import 'package:marsa_app/logic/blocs/settings/settings_state.dart';

class SettingsScreenNew extends StatefulWidget {
  const SettingsScreenNew({super.key});

  @override
  State<SettingsScreenNew> createState() => _SettingsScreenNewState();
}

class _SettingsScreenNewState extends State<SettingsScreenNew> {
  String _selectedFont = 'League Spartan';
  double _fontSize = 14.0;
  String _selectedLanguage = 'vi';

  final List<String> _fonts = [
    'League Spartan',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFont = prefs.getString('selected_font') ?? 'League Spartan';
      _fontSize = prefs.getDouble('font_size') ?? 14.0;
      _selectedLanguage = prefs.getString('language') ?? 'vi';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_font', _selectedFont);
    await prefs.setDouble('font_size', _fontSize);
    await prefs.setString('language', _selectedLanguage);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã lưu cài đặt'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  void _showFontPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn font chữ',
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._fonts.map((font) {
                final isSelected = font == _selectedFont;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedFont = font;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          font,
                          style: TextStyle(
                            color: theme.colorScheme.onBackground,
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cài đặt',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              'Giao diện & Hiển thị',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Settings Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Dark Mode Toggle with BLoC
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      final isDarkMode = state is SettingsLoaded
                          ? state.isDarkMode
                          : false;

                      return Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.dark_mode,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chế độ tối',
                                  style: TextStyle(
                                    color: theme.colorScheme.onBackground,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  isDarkMode
                                      ? 'Bật/tắt Dark Mode'
                                      : 'Bật/tắt Dark Mode',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDarkMode,
                            onChanged: (value) {
                              context.read<SettingsBloc>().add(
                                ToggleThemeMode(value),
                              );
                            },
                            activeColor: theme.colorScheme.primary,
                          ),
                        ],
                      );
                    },
                  ),

                  const Divider(height: 32),

                  // Font Selection (Clickable Container)
                  InkWell(
                    onTap: _showFontPicker,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.font_download,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Font chữ',
                                  style: TextStyle(
                                    color: theme.colorScheme.onBackground,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _selectedFont,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  // Font Size Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.text_fields,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cỡ chữ',
                              style: TextStyle(
                                color: theme.colorScheme.onBackground,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${_fontSize.toInt()}',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('A', style: TextStyle(fontSize: 12)),
                          Expanded(
                            child: Slider(
                              value: _fontSize,
                              min: 12.0,
                              max: 24.0,
                              divisions: 12,
                              activeColor: theme.colorScheme.secondary,
                              onChanged: (value) {
                                setState(() {
                                  _fontSize = value;
                                });
                              },
                            ),
                          ),
                          const Text('A', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      Center(
                        child: Text(
                          'Thay đổi kích thước chữ toàn bộ ứng dụng',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Language Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.language,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Ngôn ngữ giao diện',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLanguage = 'en';
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _selectedLanguage == 'en'
                                    ? theme.colorScheme.primary.withOpacity(0.1)
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: _selectedLanguage == 'en'
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Tiếng Anh',
                                style: TextStyle(
                                  color: _selectedLanguage == 'en'
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onBackground,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLanguage = 'vi';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedLanguage == 'vi'
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                foregroundColor: _selectedLanguage == 'vi'
                                    ? Colors.white
                                    : theme.colorScheme.onBackground,
                                side: BorderSide(
                                  color: _selectedLanguage == 'vi'
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Tiếng Việt'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lưu cài đặt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
