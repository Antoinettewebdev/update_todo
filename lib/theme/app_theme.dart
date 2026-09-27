import 'package:flutter/material.dart';

class AppTheme {
  static const Color _background = Color(0xFFF8F9FA);
  static const Color _surface = Colors.white;
  static const Color _primary = Color(0xFF1A1A2E);
  static const Color _accent = Color(0xFF4A6CF7);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accent,
        brightness: Brightness.light,
        surface: _surface,
      ),
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _primary,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE8EAED), thickness: 1),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: _primary,
        displayColor: _primary,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
