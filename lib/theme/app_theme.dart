import 'package:flutter/material.dart';

class AppTheme {
  // Light Mode Color Palette
  static const Color background = Color(0xFFFAF7F2); // Soft warm cream
  static const Color surface = Color(0xFFFFFFFF);     // Plain white for cards
  
  static const Color primary = Color(0xFFB19CD9);     // Soft Lavender
  static const Color primaryDark = Color(0xFF7E64AD); // Deep Lavender (for text)
  static const Color primaryLight = Color(0xFFE8DFFF); // Light Lavender
  
  static const Color secondary = Color(0xFFA2B997);   // Sage Green
  static const Color secondaryDark = Color(0xFF5D7453); // Deep Sage
  static const Color secondaryLight = Color(0xFFE2EFE0); // Light Sage
  
  static const Color accent = Color(0xFFFFB7B2);      // Pastel Coral/Pink
  static const Color accentLight = Color(0xFFFFE5E3); // Light Coral
  
  static const Color warning = Color(0xFFFFDAC1);     // Pastel Yellow/Orange
  static const Color warningDark = Color(0xFF9E6539);
  
  static const Color info = Color(0xFFB5EAD7);        // Pastel Mint
  static const Color infoDark = Color(0xFF407F66);

  static const Color textDark = Color(0xFF333333);    // Soft charcoal
  static const Color textLight = Color(0xFF666666);   // Cool gray
  static const Color border = Color(0xFFEAEAEA);      // Soft divider

  // Dark Mode Color Palette
  static const Color darkBackground = Color(0xFF121216); // OLED Charcoal
  static const Color darkSurface = Color(0xFF1E1E26);    // Dark Surface
  static const Color darkBorder = Color(0xFF2D2D3A);     // Subtle Dark Divider
  static const Color darkText = Color(0xFFF1F1F5);       // Crisp white-gray
  static const Color darkTextLight = Color(0xFFA2A2B2);  // Muted light gray
  static const Color darkPrimary = Color(0xFFC8B6FF);    // Glowing Lavender
  static const Color darkSecondary = Color(0xFF70E000);  // Energetic Sage/Lime
  static const Color darkAccent = Color(0xFFFF70A6);     // Neon Coral

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: accent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 1),
        ),
        hintStyle: const TextStyle(color: textLight, fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: secondary,
        surface: darkSurface,
        error: darkAccent,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: darkText,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkText),
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkAccent, width: 1),
        ),
        hintStyle: const TextStyle(color: darkTextLight, fontSize: 14),
      ),
    );
  }
}
