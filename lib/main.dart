import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: const SudokuApp(),
    ),
  );
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    final light = _buildLightTheme();
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4B5CF5),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F111A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF161A2A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF161A2A),
        selectedItemColor: Color(0xFF6C82FF),
        unselectedItemColor: Color(0xFF59607A),
      ),
    );

    return MaterialApp(
      title: 'Sudoku Master',
      locale: const Locale('uk'),
      themeMode: switch (app.theme) {
        AppTheme.system => ThemeMode.system,
        AppTheme.light => ThemeMode.light,
        AppTheme.dark => ThemeMode.dark,
      },
      theme: light,
      darkTheme: dark,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    const primary = Color(0xFF4B5CF5);
    const background = Color(0xFFF3F5FC);
    const surface = Colors.white;

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        background: background,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: surface,
        foregroundColor: Color(0xFF1A1F36),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1F36),
        ),
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'SF Pro Display',
        bodyColor: const Color(0xFF1F2437),
        displayColor: const Color(0xFF1F2437),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dividerColor: const Color(0xFFE4E7F5),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF9AA3B9),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
