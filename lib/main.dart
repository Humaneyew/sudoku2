import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'home_screen.dart';
import 'models.dart';
import 'undo_ad_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const locales = ['en', 'ru', 'uk', 'de', 'fr', 'zh', 'hi'];
  await Future.wait(locales.map(initializeDateFormatting));

  final appState = AppState();
  await appState.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider(create: (_) => UndoAdController()),
      ],
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
    const primaryBlue = Color(0xFF3B82F6);
    const navigationSelected = Color(0xFF5B9BFA);
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F111A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF161A2A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF161A2A),
        selectedItemColor: navigationSelected,
        unselectedItemColor: const Color(0xFF59607A),
      ),
    ).copyWith(pageTransitionsTheme: _pageTransitionsTheme);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: app.lang.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
    const primary = Color(0xFF3B82F6);
    const background = Color(0xFFEAF2FF);
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
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      dividerColor: const Color(0xFFE4E7F5),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF9AA3B9),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      pageTransitionsTheme: _pageTransitionsTheme,
    );
  }
}

const _pageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _SudokuPageTransitionsBuilder(),
    TargetPlatform.iOS: _SudokuPageTransitionsBuilder(),
    TargetPlatform.linux: _SudokuPageTransitionsBuilder(),
    TargetPlatform.macOS: _SudokuPageTransitionsBuilder(),
    TargetPlatform.windows: _SudokuPageTransitionsBuilder(),
  },
);

class _SudokuPageTransitionsBuilder extends PageTransitionsBuilder {
  const _SudokuPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      return child;
    }

    final primary = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final secondary = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(primary),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.25, 0),
        ).animate(secondary),
        child: child,
      ),
    );
  }
}
