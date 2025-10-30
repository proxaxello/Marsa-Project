import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsa_app/logic/blocs/settings/settings_bloc.dart';
import 'package:marsa_app/logic/blocs/settings/settings_event.dart';
import 'package:marsa_app/logic/blocs/settings/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          // Default values if state is not loaded yet
          bool isDarkMode = false;
          bool practiceRemindersEnabled = true;
          
          // Update values if settings are loaded
          if (state is SettingsLoaded) {
            isDarkMode = state.isDarkMode;
            practiceRemindersEnabled = state.practiceRemindersEnabled;
          }
          
          return ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              print('Profile tapped');
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Subscription'),
            subtitle: const Text('Free Plan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              print('Subscription tapped');
            },
          ),
          const Divider(),
          
          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Practice Reminders'),
            subtitle: const Text('Daily reminders to practice'),
            value: practiceRemindersEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(TogglePracticeReminders(value));
              print('Practice Reminders: $value');
            },
          ),
          const Divider(),
          
          // General Section
          _buildSectionHeader('General'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: isDarkMode,
            onChanged: (value) {
              context.read<SettingsBloc>().add(ToggleThemeMode(value));
              print('Dark Mode: $value');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              print('Help & Support tapped');
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              print('Privacy Policy tapped');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Marsa'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              print('About Marsa tapped');
            },
          ),
          const SizedBox(height: 24),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                print('Logout tapped');
              },
              child: const Text('Logout'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
        },
      ),
    );
  }
  
  // Helper method to build section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
