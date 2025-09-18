import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'home_screen.dart';
import 'models.dart';
import 'theme.dart';
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

class SudokuApp extends StatefulWidget {
  const SudokuApp({super.key});

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> with WidgetsBindingObserver {
  Brightness _platformBrightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final activeTheme = app.resolvedTheme(_platformBrightness);
    final theme = buildSudokuTheme(activeTheme)
        .copyWith(pageTransitionsTheme: _pageTransitionsTheme);

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
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaleFactor: app.fontScale),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
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
