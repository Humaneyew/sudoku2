import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'models.dart';
import 'settings_page.dart';
import 'theme.dart';
import 'widgets/board.dart';
import 'widgets/control_panel.dart';
import 'widgets/theme_menu.dart';

final _elapsedMsExpando = Expando<int>('elapsedMs');

extension _GameStateElapsedMs on GameState {
  int get elapsedMs => _elapsedMsExpando[this] ?? 0;

  set elapsedMs(int value) => _elapsedMsExpando[this] = value;
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  final ValueNotifier<int> _elapsedVN = ValueNotifier<int>(0);
  Timer? _t;
  int _observedSession = -1;
  bool _victoryShown = false;
  bool _failureShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final app = context.read<AppState>();
    final startMs = app.current?.elapsedMs ?? 0;
    _startTimer(app, startMs);
  }

  void _startTimer(AppState app, int startMs) {
    _t?.cancel();
    _elapsedVN.value = startMs;
    final current = app.current;
    if (current != null) {
      current.elapsedMs = startMs;
    }
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedVN.value += 1000;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _t?.cancel();

    final app = context.read<AppState>();
    if (app.current != null) {
      app.current!.elapsedMs = _elapsedVN.value;
      app.save();
    }

    _elapsedVN.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final app = context.read<AppState>();
      if (app.current != null) {
        app.current!.elapsedMs = _elapsedVN.value;
        app.save();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final game = app.current;
    final l10n = AppLocalizations.of(context)!;

    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.gameScreenTitle)),
        body: Center(
          child: Text(l10n.noActiveGameMessage),
        ),
      );
    }

    if (_observedSession != app.sessionId) {
      _observedSession = app.sessionId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startTimer(app, app.current?.elapsedMs ?? 0);
        _victoryShown = false;
        _failureShown = false;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleGameState(app);
    });

    final difficulty =
        (app.currentDifficulty ?? app.featuredStatsDifficulty).title(l10n);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _GameHeader(
              elapsed: _elapsedVN,
              onBack: () => Navigator.pop(context),
              onRestart: () {
                app.restartCurrentPuzzle();
                app.current?.elapsedMs = 0;
                _startTimer(app, 0);
              },
              onOpenTheme: () => showThemeMenu(context),
              onSettings: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: _StatusBar(
                difficulty: difficulty,
                stars: app.currentScore,
                lives: app.livesLeft,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: const Column(
                  children: [
                    Board(),
                    SizedBox(height: 20),
                    ControlPanel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGameState(AppState app) {
    if (app.current == null) return;

    if (app.isSolved && !app.gameCompleted) {
      final ms = _elapsedVN.value;
      app.current?.elapsedMs = ms;
      app.completeGame(ms);
      if (!_victoryShown) {
        _victoryShown = true;
        _showVictoryDialog(app);
      }
    } else if (app.isOutOfLives) {
      if (!_failureShown) {
        _failureShown = true;
        _showOutOfLivesDialog(app);
      }
    } else {
      _failureShown = false;
    }
  }

  void _showVictoryDialog(AppState app) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final reduceMotion = MediaQuery.of(context).disableAnimations;
        final duration = reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 220);
        final theme = Theme.of(context);
        final colors = theme.extension<SudokuColors>()!;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: reduceMotion ? 1.0 : 0.85, end: 1.0),
          duration: duration,
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Dialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: colors.victoryBadgeGradient,
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: theme.colorScheme.onPrimary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.victoryTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.victoryMessage(formatDuration(_elapsedVN.value)),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text(l10n.backToHome),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            final diff = app.currentDifficulty ??
                                app.featuredStatsDifficulty;
                            app.startGame(diff);
                            app.current?.elapsedMs = 0;
                            _startTimer(app, 0);
                            _victoryShown = false;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(l10n.playAnother),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showOutOfLivesDialog(AppState app) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final reduceMotion = MediaQuery.of(context).disableAnimations;
        final duration = reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 220);
        final theme = Theme.of(context);
        final colors = theme.extension<SudokuColors>()!;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: reduceMotion ? 1.0 : 0.0, end: 1.0),
          duration: duration,
          curve: Curves.easeOut,
          builder: (context, value, child) {
            final scale = reduceMotion ? 1.0 : 0.95 + 0.05 * value;
            return Opacity(
              opacity: value,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 36),
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: colors.failureBadgeGradient,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: theme.colorScheme.onPrimary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.outOfLivesTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.outOfLivesDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(l10n.restoreLifeAction),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.cancelAction),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result == true) {
      app.restoreOneLife();
      setState(() {
        _failureShown = false;
      });
    } else {
      app.registerFailure();
      app.abandonGame();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}

String formatDuration(int ms) {
  final seconds = ms ~/ 1000;
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}

class _GameHeader extends StatelessWidget {
  final ValueListenable<int> elapsed;
  final VoidCallback onBack;
  final VoidCallback onRestart;
  final VoidCallback onOpenTheme;
  final VoidCallback onSettings;

  const _GameHeader({
    required this.elapsed,
    required this.onBack,
    required this.onRestart,
    required this.onOpenTheme,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.headlineSmall?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ) ??
        const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _HeaderButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          Expanded(
            child: Column(
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: elapsed,
                  builder: (_, ms, __) => Text(
                    formatDuration(ms),
                    style: textStyle,
                  ),
                ),
              ],
            ),
          ),
          _HeaderButton(icon: Icons.palette_outlined, onTap: onOpenTheme),
          const SizedBox(width: 12),
          _HeaderButton(icon: Icons.refresh_rounded, onTap: onRestart),
          const SizedBox(width: 12),
          _HeaderButton(icon: Icons.settings_outlined, onTap: onSettings),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    return InkResponse(
      radius: 28,
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.headerButtonBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.shadowColor,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: colors.headerButtonIcon),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String difficulty;
  final int stars;
  final int lives;

  const _StatusBar({
    required this.difficulty,
    required this.stars,
    required this.lives,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            difficulty,
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ) ??
                const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: scheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  stars.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _HeartsIndicator(lives: lives),
        ],
      ),
    );
  }
}

class _HeartsIndicator extends StatelessWidget {
  final int lives;

  const _HeartsIndicator({required this.lives});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inactive = scheme.outlineVariant;
    return Row(
      children: List.generate(3, (index) {
        final active = index < lives;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            Icons.favorite,
            size: 24,
            color: active ? scheme.error : inactive,
          ),
        );
      }),
    );
  }
}
