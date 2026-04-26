import 'package:flutter/material.dart';

/// Marsa App Theme Configuration
///
/// DARK MODE COLOR PALETTE:
/// - Main Background: Navy #0a082d
/// - Secondary Block Background: #202140
/// - Block Borders: Gradient of #ff8946 (Orange) and #9bcfff (Light Blue)
/// - Text Color: White #ffffff
///
/// ICON STYLING (Multi-layered):
/// - Primary Icon Colors: #ff8946 and #53cffe
/// - Secondary/Accent Icon Colors: #1800ad and #4454ff

class AppTheme {
  // ==================== DARK MODE COLORS ====================
  static const Color darkNavyBackground = Color(0xFF011122);
  static const Color darkCardBackground = Color(0xFF202140);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFCCCCCC);

  // Gradient Border Colors
  static const Color gradientOrange = Color(0xFFFF8946);
  static const Color gradientLightBlue = Color(0xFF9bcfff);

  // Primary Icon Colors
  static const Color iconOrange = Color(0xFFff8946);
  static const Color iconCyan = Color(0xFF53cffe);

  // Secondary Icon Colors
  static const Color iconDeepBlue = Color(0xFF1800ad);
  static const Color iconBrightBlue = Color(0xFF4454ff);

  // Accent Colors
  static const Color accentGreen = Color(0xFF57d9b2);

  // ==================== LIGHT MODE COLORS ====================
  static const Color lightBackground = Color(0xFFF8F8F8);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(
    0xFF0a082d,
  ); // Deep Navy for contrast
  static const Color lightTextSecondary = Color(0xFF4B4B4B);

  // ==================== GRADIENT DEFINITIONS ====================
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkNavyBackground, Color(0xFF1a1850)],
  );

  static const LinearGradient orangeBlueBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientOrange, gradientLightBlue],
  );

  static const LinearGradient blueOrangeBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientLightBlue, gradientOrange],
  );

  // ==================== THEME DATA ====================

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: iconBrightBlue,
        secondary: iconOrange,
        surface: darkCardBackground,
        background: darkNavyBackground,
        onPrimary: darkTextPrimary,
        onSecondary: darkTextPrimary,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        error: Color(0xFFf64a00),
      ),

      // Scaffold
      scaffoldBackgroundColor: darkNavyBackground,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: gradientOrange.withOpacity(0.3), width: 1),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: darkTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 14),
        bodySmall: TextStyle(color: darkTextSecondary, fontSize: 12),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: iconCyan, size: 24),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCardBackground.withOpacity(0.8),
        selectedItemColor: iconOrange,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: darkTextSecondary, fontSize: 16),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: iconDeepBlue,
          foregroundColor: darkTextPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1800ad),
        secondary: Color(0xFFf64a00),
        surface: lightCardBackground,
        background: lightBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onBackground: lightTextPrimary,
        error: Color(0xFFf64a00),
      ),

      // Scaffold
      scaffoldBackgroundColor: lightBackground,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: lightCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: lightTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 14),
        bodySmall: TextStyle(color: lightTextSecondary, fontSize: 12),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: Color(0xFF1800ad), size: 24),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFf64a00),
        unselectedItemColor: Color(0xFF999999),
        type: BottomNavigationBarType.fixed,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8E8E8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 16),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1800ad),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  /// Get gradient border decoration for cards
  static BoxDecoration getGradientBorderDecoration({
    required bool isDark,
    bool alternateGradient = false,
    double borderRadius = 20,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      color: isDark ? darkCardBackground : lightCardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(width: 0, color: Colors.transparent),
      gradient: isDark
          ? (alternateGradient
                ? blueOrangeBorderGradient
                : orangeBlueBorderGradient)
          : null,
    );
  }

  /// Get glassmorphism decoration
  static BoxDecoration getGlassmorphismDecoration({
    required bool isDark,
    double borderRadius = 20,
    double opacity = 0.22,
  }) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withOpacity(opacity)
          : Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
