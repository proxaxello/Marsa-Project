import 'package:flutter/material.dart';

/// Neo-Brutalism Design System for Marsa App
/// 
/// Characteristics:
/// - Bold colors and high contrast
/// - Thick black borders (3-4px)
/// - Harsh, stark drop shadows
/// - Intentionally "undesigned" or raw aesthetic
/// - Raw typography and slightly asymmetrical layouts
/// - No gradients, blurs, or subtle shadows
class NeoBrutalTheme {
  // Primary Color Palette
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color electricYellow = Color(0xFFFFE500);
  static const Color hotPink = Color(0xFFFF006E);
  static const Color cyanBlue = Color(0xFF00F5FF);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  
  // Border Configuration
  static const double borderWidthThin = 3.0;
  static const double borderWidthThick = 4.0;
  static const double borderWidthExtraThick = 6.0;
  
  // Shadow Configuration
  static BoxShadow shadowSmall = const BoxShadow(
    color: pureBlack,
    offset: Offset(2, 2),
    blurRadius: 0,
  );
  
  static BoxShadow shadowMedium = const BoxShadow(
    color: pureBlack,
    offset: Offset(4, 4),
    blurRadius: 0,
  );
  
  static BoxShadow shadowLarge = const BoxShadow(
    color: pureBlack,
    offset: Offset(6, 6),
    blurRadius: 0,
  );
  
  static BoxShadow shadowExtraLarge = const BoxShadow(
    color: pureBlack,
    offset: Offset(8, 8),
    blurRadius: 0,
  );
  
  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: pureBlack,
    height: 1.0,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: pureBlack,
    height: 1.1,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: pureBlack,
    height: 1.2,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: pureBlack,
    height: 1.4,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: pureBlack,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: pureBlack,
    height: 1.4,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: pureBlack,
    letterSpacing: 1.2,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    color: pureBlack,
    letterSpacing: 1.2,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: pureBlack,
    letterSpacing: 0.5,
  );
  
  // Component Builders
  
  /// Creates a Neo-Brutal container with border and shadow
  static BoxDecoration containerDecoration({
    required Color backgroundColor,
    double borderWidth = borderWidthThick,
    BoxShadow? shadow,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(color: pureBlack, width: borderWidth),
      boxShadow: [shadow ?? shadowMedium],
    );
  }
  
  /// Creates a Neo-Brutal button decoration
  static BoxDecoration buttonDecoration({
    required Color backgroundColor,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(color: pureBlack, width: borderWidthThick),
      boxShadow: isPressed ? [] : [shadowMedium],
    );
  }
  
  /// Creates a Neo-Brutal card decoration with optional rotation
  static BoxDecoration cardDecoration({
    Color backgroundColor = pureWhite,
    BoxShadow? shadow,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(color: pureBlack, width: borderWidthThick),
      boxShadow: [shadow ?? shadowLarge],
    );
  }
  
  /// Creates a Neo-Brutal input decoration
  static InputDecoration inputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Colors.black38,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
  
  /// Creates a Neo-Brutal badge
  static Widget badge({
    required String text,
    required Color backgroundColor,
    Color textColor = pureBlack,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: pureBlack, width: borderWidthThin),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }
  
  /// Creates a Neo-Brutal icon button
  static Widget iconButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
    double size = 40,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: pureBlack, width: borderWidthThin),
          boxShadow: [shadowSmall],
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: pureBlack,
        ),
      ),
    );
  }
  
  /// Creates a Neo-Brutal primary button
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = neonGreen,
    IconData? icon,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      decoration: buttonDecoration(backgroundColor: backgroundColor),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 24, color: pureBlack),
                  const SizedBox(width: 12),
                ],
                Text(
                  text.toUpperCase(),
                  style: buttonText.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Creates a Neo-Brutal card with rotation effect
  static Widget rotatedCard({
    required Widget child,
    double rotation = 0.01,
    Color backgroundColor = pureWhite,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        decoration: cardDecoration(backgroundColor: backgroundColor),
        child: child,
      ),
    );
  }
  
  /// Creates a Neo-Brutal status banner
  static Widget statusBanner({
    required String text,
    required IconData icon,
    required Color backgroundColor,
    bool isOnline = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: containerDecoration(backgroundColor: backgroundColor),
      child: Row(
        children: [
          Icon(icon, size: 24, color: pureBlack),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: pureBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Creates a Neo-Brutal search bar
  static Widget searchBar({
    required TextEditingController controller,
    required Function(String) onChanged,
    String hintText = 'SEARCH...',
    VoidCallback? onClear,
  }) {
    return Container(
      height: 64,
      decoration: containerDecoration(
        backgroundColor: pureWhite,
        shadow: shadowLarge,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: pureBlack,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black38,
                  fontSize: 18,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 32,
                  color: pureBlack,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty && onClear != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 28, color: pureBlack),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
  
  /// Creates a Neo-Brutal hero section
  static Widget heroSection({
    required String title,
    String? subtitle,
    String? description,
    Color backgroundColor = hotPink,
    double rotation = -0.02,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: containerDecoration(
          backgroundColor: backgroundColor,
          shadow: shadowExtraLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: headingLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: bodyLarge.copyWith(fontSize: 18),
              ),
            ],
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Material Theme Data for the app
  static ThemeData getMaterialTheme() {
    return ThemeData(
      primaryColor: neonGreen,
      scaffoldBackgroundColor: pureWhite,
      colorScheme: const ColorScheme.light(
        primary: neonGreen,
        secondary: electricYellow,
        tertiary: hotPink,
        surface: pureWhite,
        error: hotPink,
      ),
      fontFamily: 'System',
      textTheme: const TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelSmall: labelSmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: pureBlack,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: pureBlack, width: borderWidthThick),
          ),
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: pureBlack, width: borderWidthThick),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: pureBlack, width: borderWidthThick),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: pureBlack, width: borderWidthExtraThick),
        ),
        filled: true,
        fillColor: pureWhite,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: pureBlack, width: borderWidthThick),
        ),
        color: pureWhite,
      ),
      useMaterial3: true,
    );
  }
}
