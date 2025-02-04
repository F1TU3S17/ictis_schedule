import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2E5AAC), // Основной синий цвет
    secondary: const Color(0xFF4CAF50), // Акцентный зелёный
    tertiary: const Color(0xFF607D8B), 
    surface: const Color(0xFFF5F5F5), // Фон
    background: Colors.white,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w600,

    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.bold,
      fontSize: 24
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16
    )
    
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF2E5AAC),
    foregroundColor: Colors.white,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: const Color(0xFF2E5AAC),
  )
);