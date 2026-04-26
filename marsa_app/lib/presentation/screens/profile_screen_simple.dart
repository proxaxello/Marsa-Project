import 'package:flutter/material.dart';
import 'package:marsa_app/presentation/screens/settings_screen_new.dart';

/// Simple Profile Screen - redirects to Settings
class ProfileScreenSimple extends StatelessWidget {
  const ProfileScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreenNew();
  }
}
