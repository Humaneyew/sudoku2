import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'championship/championship_model.dart';
import 'championship/championship_page.dart';
import 'home_screen.dart';
import 'models.dart' as models;
import 'screens/intro_screen.dart';
import 'theme.dart';
import 'hint_ad_controller.dart';
import 'life_ad_controller.dart';
import 'undo_ad_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final defaultLocale = ui.PlatformDispatcher.instance.locale.toLanguageTag();
  await initializeDateFormatting(defaultLocale);

  final appState = models.AppState();
  await appState.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider<ChampionshipModel>(
          create: (_) {
            final model = ChampionshipModel();
            model.loadFromPrefs();
            model.loadPermaLeaderboard();
            return model;
          },
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => LifeAdController()),
        ChangeNotifierProvider(create: (_) => UndoAdController()),
        ChangeNotifierProvider(create: (_) => HintAdController()),
      ],
      child: const SudokuApp(),
    ),
  );
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<models.AppState>();
    final activeTheme = app.resolvedTheme();
    final theme = buildSudokuTheme(
      activeTheme,
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
      theme: theme,
      themeAnimationDuration: const Duration(milliseconds: 250),
      themeAnimationCurve: Curves.easeOutCubic,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaleFactor: app.fontScale),
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: '/intro',
      routes: {
        '/intro': (context) => const IntroScreen(),
        '/home': (context) => const HomeScreen(),
        '/championship': (context) => const ChampionshipPage(),
      },
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
