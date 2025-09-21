import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'championship/championship_model.dart';
import 'models.dart';
import 'settings_page.dart';
import 'theme.dart';
import 'widgets/board.dart';
import 'widgets/control_panel.dart';
import 'widgets/theme_menu.dart';

final _elapsedMsExpando = Expando<int>('elapsedMs');

const int _kInitialHints = 3;
const int _kInitialLives = 3;
const double _kGameplayUiScale = 1.1;

extension _GameStateElapsedMs on GameState {
  int get elapsedMs => _elapsedMsExpando[this] ?? 0;

  set elapsedMs(int value) => _elapsedMsExpando[this] = value;
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final ValueNotifier<int> _elapsedVN = ValueNotifier<int>(0);
  Timer? _t;
  int _observedSession = -1;
  bool _victoryShown = false;
  bool _failureShown = false;
  AppState? _appState;
  late final VoidCallback _appStateListener;
  bool _gameStateScheduled = false;
  OverlayEntry? _scoreToastEntry;
  AnimationController? _scoreToastController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appStateListener = _handleAppStateChanged;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribeToAppState();
  }

  void _subscribeToAppState() {
    final app = context.read<AppState>();
    if (identical(app, _appState)) {
      return;
    }

    _appState?.removeListener(_appStateListener);
    _appState = app;
    _observedSession = app.sessionId;
    _victoryShown = false;
    _failureShown = false;
    final startMs = app.current?.elapsedMs ?? 0;
    _startTimer(app, startMs);
    app.addListener(_appStateListener);
    _scheduleHandleGameState();
  }

  void _handleAppStateChanged() {
    final app = _appState;
    if (app == null || !mounted) {
      return;
    }

    if (_observedSession != app.sessionId) {
      _observedSession = app.sessionId;
      _victoryShown = false;
      _failureShown = false;
      _startTimer(app, app.current?.elapsedMs ?? 0);
    }

    _scheduleHandleGameState();
  }

  void _scheduleHandleGameState() {
    if (_gameStateScheduled) {
      return;
    }
    _gameStateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _gameStateScheduled = false;
      if (!mounted) {
        return;
      }
      final app = _appState;
      if (app == null) {
        return;
      }
      await _handleGameState(app);
    });
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

    final app = _appState;
    if (app != null) {
      app.removeListener(_appStateListener);
      if (app.current != null) {
        app.current!.elapsedMs = _elapsedVN.value;
        unawaited(app.save());
      }
    }

    _scoreToastController?.dispose();
    _scoreToastEntry?.remove();
    _scoreToastController = null;
    _scoreToastEntry = null;

    _elapsedVN.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final app = _appState ?? context.read<AppState>();
      if (app.current != null) {
        app.current!.elapsedMs = _elapsedVN.value;
        unawaited(app.save());
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

    final media = MediaQuery.of(context);
    const scale = _kGameplayUiScale;

    return Scaffold(
      body: MediaQuery(
        data: media.copyWith(
          textScaleFactor: media.textScaleFactor * scale,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _GameHeader(
                scale: scale,
                elapsed: _elapsedVN,
                onBack: () {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
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
                padding: EdgeInsets.symmetric(
                  horizontal: 24 / scale,
                  vertical: 12 * scale,
                ),
                child: const _StatusBarContainer(scale: scale),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 12 * scale, 0, 32 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final baseWidth = math.max(0.0, width - 40);
                          final targetWidth = math.min(width, baseWidth * scale);
                          final horizontalPadding =
                              math.max(0.0, (width - targetWidth) / 2);
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: const Board(scale: scale),
                          );
                        },
                      ),
                      const SizedBox(height: 20 * scale),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final baseWidth = math.max(0.0, width - 24);
                          final targetWidth = math.min(width, baseWidth * scale);
                          final horizontalPadding =
                              math.max(0.0, (width - targetWidth) / 2);
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: const ControlPanel(scale: scale),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGameState(AppState app) async {
    if (app.current == null) return;

    if (app.isSolved && !app.gameCompleted) {
      final ms = _elapsedVN.value;
      app.current?.elapsedMs = ms;
      app.completeGame(ms);
      ChampionshipModel? championship;
      try {
        championship = context.read<ChampionshipModel?>();
      } catch (_) {
        championship = null;
      }
      int awardedDelta = 0;
      int? previousRank;
      if (championship != null) {
        try {
          final difficulty = app.currentDifficulty ?? app.featuredDifficulty;
          final mistakes =
              (_kInitialLives - app.livesLeft).clamp(0, _kInitialLives).toInt();
          final hintsUsed =
              (_kInitialHints - app.hintsLeft).clamp(0, _kInitialHints).toInt();
          final isDaily = app.activeDailyChallengeDate != null;
          previousRank = championship.myRank;
          final gameId = app.ensureCurrentGameId();
          awardedDelta = await championship.awardScoreForGame(
            difficulty: difficulty,
            timeMs: ms,
            mistakes: mistakes,
            hints: hintsUsed,
            gameId: gameId,
            isDailyChallenge: isDaily,
          );
        } catch (_) {}
        if (!mounted) {
          return;
        }
        if (awardedDelta > 0) {
          final l10n = AppLocalizations.of(context)!;
          _showScoreToast(l10n, awardedDelta);
          if (previousRank != null) {
            _maybeTriggerRankHaptic(
              app,
              previousRank,
              championship.myRank,
            );
          }
        }
        try {
          championship.completeCurrentRound();
        } catch (_) {}
      }
      if (!_victoryShown && mounted) {
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

  void _showScoreToast(AppLocalizations l10n, int delta) {
    final overlay = Overlay.of(context);
    if (overlay == null) {
      return;
    }

    _scoreToastController?.dispose();
    _scoreToastController = null;
    _scoreToastEntry?.remove();
    _scoreToastEntry = null;

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final animationDuration =
        reduceMotion ? const Duration(milliseconds: 1) : const Duration(milliseconds: 240);

    final controller = AnimationController(
      duration: animationDuration,
      reverseDuration: animationDuration,
      vsync: this,
    );

    final Animation<double> opacityAnimation;
    final Animation<Offset> slideAnimation;
    if (reduceMotion) {
      opacityAnimation = const AlwaysStoppedAnimation<double>(1.0);
      slideAnimation = const AlwaysStoppedAnimation<Offset>(Offset.zero);
    } else {
      final curved = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      opacityAnimation = curved;
      slideAnimation = Tween<Offset>(
        begin: const Offset(0, -0.12),
        end: Offset.zero,
      ).animate(curved);
    }

    final entry = OverlayEntry(
      builder: (context) {
        final media = MediaQuery.of(context);
        final text = '+$delta ${l10n.pointsShort}';
        return Positioned(
          top: media.padding.top + 16,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: opacityAnimation,
                  child: _ScoreToastMessage(
                    text: text,
                    scale: _kGameplayUiScale,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _scoreToastEntry = entry;
    _scoreToastController = controller;
    controller.forward();

    Future.delayed(const Duration(milliseconds: 1200), () async {
      if (!mounted || _scoreToastController != controller) {
        return;
      }
      if (!reduceMotion) {
        try {
          await controller.reverse();
        } catch (_) {
          return;
        }
      }
      if (_scoreToastController == controller) {
        controller.dispose();
        entry.remove();
        _scoreToastController = null;
        _scoreToastEntry = null;
      }
    });
  }

  void _maybeTriggerRankHaptic(AppState app, int oldRank, int newRank) {
    if (!app.vibrationEnabled) {
      return;
    }
    if (newRank >= oldRank) {
      return;
    }
    const thresholds = [100, 50, 10];
    for (final threshold in thresholds) {
      if (oldRank > threshold && newRank <= threshold) {
        HapticFeedback.lightImpact();
        break;
      }
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
                            if (!context.mounted) {
                              return;
                            }
                            final navigator = Navigator.of(context);
                            navigator.pop();
                            navigator.pop();
                          },
                          child: Text(l10n.backToHome),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!context.mounted) {
                              return;
                            }
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
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
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
                    onPressed: () {
                      if (context.mounted) {
                        Navigator.pop(context, false);
                      }
                    },
                    child: Text(l10n.cancelAction),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      app.restoreOneLife();
      _failureShown = false;
    } else {
      app.registerFailure();
      app.abandonGame();
      if (context.mounted) {
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
  final double scale;
  final ValueListenable<int> elapsed;
  final VoidCallback onBack;
  final VoidCallback onRestart;
  final VoidCallback onOpenTheme;
  final VoidCallback onSettings;

  const _GameHeader({
    required this.scale,
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
      padding: EdgeInsets.fromLTRB(16 / scale, 8 * scale, 16 / scale, 0),
      child: Row(
        children: [
          _HeaderButton(
            scale: scale,
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
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
          _HeaderButton(
            scale: scale,
            icon: Icons.palette_outlined,
            onTap: onOpenTheme,
          ),
          SizedBox(width: 12 * scale),
          _HeaderButton(
            scale: scale,
            icon: Icons.refresh_rounded,
            onTap: onRestart,
          ),
          SizedBox(width: 12 * scale),
          _HeaderButton(
            scale: scale,
            icon: Icons.settings_outlined,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double scale;

  const _HeaderButton({required this.icon, required this.onTap, required this.scale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final radiusValue = 24 * scale;
    final borderRadius = BorderRadius.circular(radiusValue);
    final blurRadius = 12 * scale;
    final offsetY = 6 * scale;
    return InkResponse(
      radius: 28 * scale,
      onTap: onTap,
      child: Container(
        width: 48 * scale,
        height: 48 * scale,
        decoration: BoxDecoration(
          color: colors.headerButtonBackground,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: colors.shadowColor,
              blurRadius: blurRadius,
              offset: Offset(0, offsetY),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: colors.headerButtonIcon,
          size: 24 * scale,
        ),
      ),
    );
  }
}

class _StatusBarContainer extends StatelessWidget {
  final double scale;

  const _StatusBarContainer({required this.scale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Selector<AppState, _StatusBarData?>(
      selector: (_, app) {
        final current = app.current;
        if (current == null) {
          return null;
        }
        final difficulty =
            app.currentDifficulty ?? app.featuredStatsDifficulty;
        return _StatusBarData(
          difficulty: difficulty,
          stars: app.currentScore,
          lives: app.livesLeft,
        );
      },
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, data, _) {
        if (data == null) {
          return const SizedBox.shrink();
        }
        return _StatusBar(
          scale: scale,
          difficulty: data.difficulty.title(l10n),
          stars: data.stars,
          lives: data.lives,
        );
      },
    );
  }
}

class _StatusBarData {
  final Difficulty difficulty;
  final int stars;
  final int lives;

  const _StatusBarData({
    required this.difficulty,
    required this.stars,
    required this.lives,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _StatusBarData &&
            other.difficulty == difficulty &&
            other.stars == stars &&
            other.lives == lives;
  }

  @override
  int get hashCode => Object.hash(difficulty, stars, lives);
}

const double _statusBarRadiusValue = 28;
const double _statusBarBadgeRadiusValue = 18;

class _StatusBar extends StatelessWidget {
  final String difficulty;
  final int stars;
  final int lives;
  final double scale;

  const _StatusBar({
    required this.difficulty,
    required this.stars,
    required this.lives,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final scheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(_statusBarRadiusValue * scale);
    final badgeRadius = BorderRadius.circular(_statusBarBadgeRadiusValue * scale);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20 / scale,
        vertical: 16 * scale,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 20 * scale,
            offset: Offset(0, 10 * scale),
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
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: 6 * scale,
            ),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.15),
              borderRadius: badgeRadius,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: scheme.secondary,
                  size: 20 * scale,
                ),
                SizedBox(width: 6 * scale),
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
          SizedBox(width: 16 * scale),
          _HeartsIndicator(lives: lives, scale: scale),
        ],
      ),
    );
  }
}

class _ScoreToastMessage extends StatelessWidget {
  final String text;
  final double scale;

  const _ScoreToastMessage({required this.text, required this.scale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final background =
        Color.alphaBlend(cs.primary.withOpacity(0.12), cs.surface);
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24 * scale),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.18),
              blurRadius: 18 * scale,
              offset: Offset(0, 12 * scale),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 12 * scale,
          ),
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ) ??
                TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
          ),
        ),
      ),
    );
  }
}

class _HeartsIndicator extends StatelessWidget {
  final int lives;
  final double scale;

  const _HeartsIndicator({required this.lives, required this.scale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inactive = scheme.outlineVariant;
    return Row(
      children: List.generate(3, (index) {
        final active = index < lives;
        return Padding(
          padding: EdgeInsets.only(left: 4 * scale),
          child: Icon(
            Icons.favorite,
            size: 24 * scale,
            color: active ? scheme.error : inactive,
          ),
        );
      }),
    );
  }
}
