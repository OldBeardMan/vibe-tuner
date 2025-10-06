import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF3EEE1),
    useMaterial3: false,
    textTheme: GoogleFonts.montserratTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF3EEE1),
      elevation: 0,
      foregroundColor: Colors.black,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFEFE6D9),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown, brightness: Brightness.light)
        .copyWith(
        surface: const Color(0xFFDCCFB8),
        primaryContainer: const Color(0xFFefe6d9),
        secondary: const Color(0xFF68625A),
        error: const Color(0xFFBC8585)
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF2F2F2F),
    useMaterial3: false,
    textTheme: GoogleFonts.montserratTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2F2F2F),
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF252525),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDDD0B8),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown, brightness: Brightness.dark)
        .copyWith(
        surface: const Color(0xFF474747),
        primaryContainer: const Color(0xFF3A3A3A),
        secondary: const Color(0xFF5E5E5E),
        error: const Color(0xFF7C4545)
    ),
  );
}
