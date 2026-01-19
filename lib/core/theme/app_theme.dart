import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F9FB), // Neutral background
    primaryColor: const Color(0xFF6C63FF), // Soft Lavender/Blue
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6C63FF),
      secondary: Color(0xFF4CAF50), // Soft Green for success/budget
      surface: Colors.white,
      onSurface: Color(0xFF2D3142),
      error: Color(0xFFFF6B6B),
    ),
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2D3142),
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3142),
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        color: const Color(0xFF4A4E69),
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        color: const Color(0xFF4A4E69),
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Color(0xFF2D3142)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF6C63FF),
      unselectedItemColor: Color(0xFF9E9E9E),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
