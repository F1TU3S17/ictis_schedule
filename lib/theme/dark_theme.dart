import 'package:flutter/material.dart';
final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2E5AAC), // Основной синий цвет
    secondary: const Color(0xFF4CAF50), // Акцентный зеленый
    tertiary: Colors.grey, // Серо-голубой
    surface: const Color(0xFF121212), // Темно-темный фон
    background: const Color(0xFF101010), // Очень темный фон приложения
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color(0xFF101010), // Темно-темный фон Scaffold

  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF161616), // Темно-темный фон AppBar
    titleTextStyle: TextStyle(
      color: Colors.white, // Белый текст в AppBar
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    foregroundColor: Colors.white, // Цвет иконок в AppBar
    elevation: 0, // Убираем тень у AppBar
  ),

  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontFamily: 'Roboto',
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Colors.white, // Белый текст для заголовков
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: Colors.white, // Белый текст для основного контента
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Roboto',
      color: Colors.white, // Светло-серый для второстепенного текста
      fontSize: 16,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Roboto',
      color: const Color(0xFF666666), // Для маленьких надписей
      fontSize: 14,
    ),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFF4CAF50), // Акцентный зеленый
    foregroundColor: Colors.white,
    elevation: 8, // Добавляем тень для выделения
  ),

  cardTheme: CardTheme(
    color: const Color.fromARGB(255, 34, 34, 34), // Темно-серый цвет для карточек (чуть светлее фона)
    elevation: 2, // Небольшая тень для объема
    // shape: RoundedRectangleBorder(
    //   borderRadius: BorderRadius.circular(12), // Сглаженные углы
    // ),
    margin: const EdgeInsets.all(8), // Отступы между карточками
  ),

  iconTheme: IconThemeData(
    color: Colors.white, // Белые иконки по умолчанию
    size: 24, // Размер иконок
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(0xFF161616), // Темно-темный фон нижней панели
    unselectedItemColor: const Color(0xFF888888), // Светло-серый для неактивных элементов
    showUnselectedLabels: true, // Показывать метки для всех элементов
    type: BottomNavigationBarType.fixed, // Фиксированный тип
  ),

  listTileTheme: ListTileThemeData(
    textColor: Colors.white, // Белый текст для элементов списка
    iconColor: Colors.white, // Белые иконки для элементов списка
  ),

  chipTheme: ChipThemeData(
    backgroundColor: const Color.fromARGB(255, 25, 25, 25), // Темно-серый фон чипов
    disabledColor: const Color(0xFF282828), // Цвет отключенных чипов
    labelStyle: TextStyle(
      color: Colors.white, // Белый текст для чипов
    ),
    padding: const EdgeInsets.all(8), // Отступы внутри чипов
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Сглаженные углы
    ),
  ),
);