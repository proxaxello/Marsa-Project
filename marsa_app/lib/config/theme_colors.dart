import 'package:flutter/material.dart';

/// Dynamic Theme Color Helper
/// Provides context-aware colors that automatically adapt to light/dark mode
class ThemeColors {
  /// Get Primary Color based on current theme
  /// Light Mode: #1800ad (Deep Blue)
  /// Dark Mode: #4454ff (Bright Blue)
  static Color getPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF4454ff) : const Color(0xFF1800ad);
  }

  /// Get Accent/Secondary Color based on current theme
  /// Light Mode: #f64a00 (Orange)
  /// Dark Mode: #FF8946 (Orange)
  static Color getAccent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFF8946) : const Color(0xFFf64a00);
  }
}
