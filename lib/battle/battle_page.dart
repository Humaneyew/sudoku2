import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import '../models.dart';
import '../settings_page.dart';
import '../theme.dart';
import '../widgets/board.dart';
import '../widgets/control_panel.dart';
import '../widgets/theme_menu.dart';
import 'flag_picker.dart';
import 'flags.dart';

class BattlePage extends StatefulWidget {
  final Difficulty? difficulty;

  const BattlePage({super.key, this.difficulty});

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final ValueNotifier<int> _elapsedVN = ValueNotifier<int>(0);
  Timer? _timer;
  Ticker? _opponentTicker;

  AppState? _appState;
  late final VoidCallback _appStateListener;

  bool _victoryShown = false;
  bool _defeatShown = false;
  bool _opponentFinished = false;
  int _observedSession = -1;

  final math.Random _random = math.Random();

  String _opponentName = '';
  double _opponentProgress = 0;
  int _opponentSolvedCells = 0;
  int _opponentTargetSolvedCells = 0;
  int _burstStartSolvedCells = 0;
  int _currentBurstCells = 0;
  bool _opponentInBurst = false;
  Duration _nextOpponentAction = Duration.zero;
  Duration _burstStartTime = Duration.zero;
  double _burstDurationSeconds = 0.5;
  double _baseOpponentTempo = 0.05; // cells per second
  Duration _lastTick = Duration.zero;

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
    if (_appState == app) {
      return;
    }

    _appState?.removeListener(_appStateListener);
    _appState = app;
    app.addListener(_appStateListener);

    _ensureGameStarted(app);
    unawaited(_promptForFlagIfNeeded(app));
    _observedSession = app.sessionId;
    _victoryShown = false;
    _defeatShown = false;
    final startMs = app.current?.elapsedMs ?? 0;
    _startTimer(app, startMs);
    _setupOpponent(app, resetProfile: true);
    _scheduleHandleGameState();
  }

  void _ensureGameStarted(AppState app) {
    if (app.current != null && app.currentMode == GameMode.battle) {
      return;
    }
    final difficulty = widget.difficulty ?? app.currentDifficulty ?? app.featuredStatsDifficulty;
    app.startBattleGame(difficulty);
  }

  Future<void> _promptForFlagIfNeeded(AppState app) async {
    if (!mounted) return;
    if (app.playerFlag != null && app.playerFlag!.isNotEmpty) {
      return;
    }

    while (mounted && (app.playerFlag == null || app.playerFlag!.isEmpty)) {
      final selected = await showFlagPicker(context);
      if (!mounted) return;

      if (selected == null || selected.isEmpty) {
        break;
      }

      final confirmed = await _showFlagConfirmationDialog(selected);
      if (!mounted) return;

      if (confirmed == true) {
        app.setPlayerFlag(selected);
        return;
      }
    }

    if (app.playerFlag == null || app.playerFlag!.isEmpty) {
      app.setPlayerFlag(kWorldFlags.first);
    }
  }

  Future<bool?> _showFlagConfirmationDialog(String flag) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final scheme = theme.colorScheme;
        return Dialog(
          backgroundColor: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10n.confirmFlagSelectionTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  flag,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.confirmFlagSelectionMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.confirm),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAppStateChanged() {
    final app = _appState;
    if (app == null || !mounted) {
      return;
    }

    if (_observedSession != app.sessionId) {
      _observedSession = app.sessionId;
      _victoryShown = false;
      _defeatShown = false;
      final startMs = app.current?.elapsedMs ?? 0;
      _startTimer(app, startMs);
      _setupOpponent(app, resetProfile: true);
    }

    _scheduleHandleGameState();
  }

  void _startTimer(AppState app, int startMs) {
    _timer?.cancel();
    _elapsedVN.value = startMs;
    final current = app.current;
    if (current != null) {
      current.elapsedMs = startMs;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedVN.value += 1000;
    });
  }

  void _setupOpponent(AppState app, {bool resetProfile = false}) {
    final game = app.current;
    if (game == null) {
      return;
    }

    if (resetProfile || _opponentName.isEmpty) {
      _opponentName = _generateOpponentName();
    }

    final initialSolved = _countSolvedCells(game);
    final totalCells = game.board.length;
    final initialProgress =
        totalCells == 0 ? 0.0 : initialSolved / totalCells.toDouble();
    setState(() {
      _opponentProgress = initialProgress;
      _opponentSolvedCells = initialSolved;
      _opponentTargetSolvedCells = initialSolved;
      _opponentFinished =
          totalCells > 0 && initialSolved >= totalCells;
      _defeatShown = false;
    });

    _baseOpponentTempo = _estimateOpponentTempo(app, totalCells);
    _opponentInBurst = false;
    _currentBurstCells = 0;
    _burstStartSolvedCells = initialSolved;
    _burstDurationSeconds = 0.5;
    _nextOpponentAction =
        Duration(milliseconds: 400 + _random.nextInt(600));
    _burstStartTime = Duration.zero;
    _lastTick = Duration.zero;

    _opponentTicker?.dispose();
    _opponentTicker = createTicker(_handleOpponentTick)..start();
  }

  void _handleOpponentTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMilliseconds / 1000.0;
    _lastTick = elapsed;
    if (dt <= 0 || _opponentFinished) {
      return;
    }
    final game = _appState?.current;
    if (game == null) {
      return;
    }
    final totalCells = game.board.length;
    if (totalCells <= 0) {
      return;
    }

    if (_opponentInBurst) {
      final elapsedInBurst =
          (elapsed - _burstStartTime).inMilliseconds / 1000.0;
      final burstProgress =
          (elapsedInBurst / _burstDurationSeconds).clamp(0.0, 1.0);
      final double solvedDouble =
          _burstStartSolvedCells + _currentBurstCells * burstProgress;
      final double clampedSolved =
          solvedDouble.clamp(0.0, totalCells.toDouble());
      final double progressValue =
          totalCells == 0 ? 0.0 : (clampedSolved / totalCells).clamp(0.0, 1.0);
      final int animatedSolved = clampedSolved.floor();
      final bool burstCompleted = burstProgress >= 1.0;

      if (!mounted) {
        _opponentTicker?.stop();
        return;
      }

      setState(() {
        if (burstCompleted) {
          final solved = math.min(_opponentTargetSolvedCells, totalCells);
          _opponentSolvedCells = solved;
          _opponentProgress = totalCells == 0
              ? 0.0
              : solved / totalCells;
          if (solved >= totalCells) {
            _opponentFinished = true;
            _opponentProgress = 1.0;
            _opponentSolvedCells = totalCells;
          }
        } else {
          _opponentProgress = progressValue;
          _opponentSolvedCells = math.min(animatedSolved, totalCells);
        }
      });

      if (burstCompleted) {
        _opponentInBurst = false;
        if (_opponentFinished) {
          _opponentTicker?.stop();
          _scheduleHandleGameState();
          return;
        }
        final expectedSeconds = _currentBurstCells /
            math.max(_baseOpponentTempo, 0.001);
        final baselinePause =
            math.max(0.2, expectedSeconds - _burstDurationSeconds);
        final jitter = 0.7 + _random.nextDouble() * 0.6;
        final pauseSeconds =
            (baselinePause * jitter).clamp(0.3, 3.5);
        _nextOpponentAction = elapsed +
            Duration(milliseconds: (pauseSeconds * 1000).round());
      }
      return;
    }

    if (elapsed >= _nextOpponentAction) {
      _startOpponentBurst(elapsed, totalCells);
    }
  }

  void _startOpponentBurst(Duration elapsed, int totalCells) {
    if (_opponentFinished) {
      return;
    }

    final remaining = totalCells - _opponentSolvedCells;
    if (remaining <= 0) {
      if (!mounted) {
        _opponentTicker?.stop();
        return;
      }
      setState(() {
        _opponentFinished = true;
        _opponentProgress = 1.0;
        _opponentSolvedCells = totalCells;
      });
      _opponentTicker?.stop();
      _scheduleHandleGameState();
      return;
    }

    final maxJump = math.min(3, remaining);
    final jump = 1 + _random.nextInt(maxJump);
    final targetSolved = math.min(totalCells, _opponentSolvedCells + jump);
    _currentBurstCells = targetSolved - _opponentSolvedCells;
    if (_currentBurstCells <= 0) {
      _nextOpponentAction =
          elapsed + Duration(milliseconds: 400 + _random.nextInt(600));
      return;
    }

    _opponentTargetSolvedCells = targetSolved;
    _burstStartSolvedCells = _opponentSolvedCells;
    _burstDurationSeconds = 0.35 + _random.nextDouble() * 0.45;
    _burstStartTime = elapsed;
    _opponentInBurst = true;
    _nextOpponentAction =
        elapsed + Duration(milliseconds: (_burstDurationSeconds * 1000).round());
  }

  int _countSolvedCells(GameState game) {
    var solved = 0;
    for (var i = 0; i < game.board.length; i++) {
      if (game.board[i] != 0 && game.board[i] == game.solution[i]) {
        solved++;
      }
    }
    return solved;
  }

  double _estimateOpponentTempo(AppState app, int totalCells) {
    final diff = app.currentDifficulty ?? app.featuredStatsDifficulty;
    final stats = app.statsFor(diff);
    int averageMs;
    if (stats.winsWithTime > 0) {
      averageMs = stats.totalTimeMs ~/ math.max(1, stats.winsWithTime);
    } else {
      averageMs = 8 * 60 * 1000;
    }
    averageMs = averageMs.clamp(4 * 60 * 1000, 18 * 60 * 1000);
    final averageSeconds = averageMs / 1000.0;
    double baseTempo;
    if (averageSeconds <= 0 || totalCells <= 0) {
      baseTempo = 0.15;
    } else {
      baseTempo = totalCells / averageSeconds;
    }
    final factor = 0.8 + _random.nextDouble() * 0.4;
    final tempo = baseTempo * factor;
    return tempo <= 0 ? 0.12 : tempo;
  }

  String _generateOpponentName() {
    const names = [
      'Max',
      'Olivia',
      'Noah',
      'Mia',
      'Aria',
      'Liam',
      'Eva',
      'Kai',
      'Nora',
      'Leo',
      'Ava',
      'Hugo',
      'Sofia',
      'Mason',
      'Elena',
      'Yuki',
      'Mateo',
      'Ivy',
      'Felix',
      'Noel',
      'Sven',
      'Amir',
      'Mila',
      'Nia',
      'Ezra',
      'Omar',
      'Elio',
      'Anya',
      'Iris',
      'Jules',
    ];
    final base = names[_random.nextInt(names.length)];
    final number = 10 + _random.nextInt(89);
    final suffixRoll = _random.nextDouble();
    if (suffixRoll < 0.4) {
      return '$base$number';
    } else if (suffixRoll < 0.7) {
      return '${base}_$number';
    }
    return '$base${number * 11}';
  }

  void _scheduleHandleGameState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final app = _appState;
      if (app == null) return;
      _handleGameState(app);
    });
  }

  void _handleGameState(AppState app) {
    final game = app.current;
    if (game == null || app.currentMode != GameMode.battle) {
      return;
    }

    if (app.isSolved && !app.gameCompleted) {
      final ms = _elapsedVN.value;
      game.elapsedMs = ms;
      app.completeBattle(ms);
      _opponentTicker?.stop();
      if (!_victoryShown) {
        _victoryShown = true;
        _showVictoryDialog(app);
      }
      return;
    }

    if (_opponentFinished && !app.isSolved && !_defeatShown) {
      _defeatShown = true;
      _opponentTicker?.stop();
      _showDefeatDialog(app);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _opponentTicker?.dispose();

    final app = _appState;
    if (app != null) {
      app.removeListener(_appStateListener);
      if (app.current != null) {
        app.current!.elapsedMs = _elapsedVN.value;
        unawaited(app.save());
      }
    }

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
    final l10n = AppLocalizations.of(context)!;
    final game = app.current;

    if (game == null || app.currentMode != GameMode.battle) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.battleTitle)),
        body: Center(child: Text(l10n.noActiveGameMessage)),
      );
    }

    final media = MediaQuery.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        title: Text(l10n.battleTitle),
        backgroundColor: scheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Center(
              child: _BattleAppBarButton(
                icon: Icons.palette_outlined,
                onTap: () => showThemeMenu(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4, top: 6, bottom: 6),
            child: Center(
              child: _BattleAppBarButton(
                icon: Icons.settings_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth * _kGameplayHorizontalPaddingFactor;
            final contentWidth =
                math.max(0.0, constraints.maxWidth - horizontalPadding * 2);
            final isTablet = media.size.shortestSide >= 600;
            final scale = _resolveGameplayScale(
              baseScale: _kGameplayUiScale,
              minScale: _kGameplayMinUiScale,
              contentWidth: contentWidth,
              availableHeight: constraints.maxHeight,
              baseTextScaleFactor: media.textScaleFactor,
              theme: theme,
              isTablet: isTablet,
            );
            final scaledMedia = media.copyWith(
              textScaleFactor: media.textScaleFactor * scale,
            );
            final availableHeight = constraints.maxHeight;
            final topPadding = _calculateGameContentTopPadding(
              availableHeight: availableHeight,
              scale: scale,
            );
            final bottomPadding = _calculateGameContentBottomPadding(
              availableHeight: availableHeight,
              scale: scale,
            );
            final bool isCompactHeight =
                !isTablet && availableHeight < _kCompactHeightBreakpoint;
            final solvedCells = _countSolvedCells(game);
            final playerProgress = solvedCells / game.board.length;

            final lives = app.livesLeft;

            return MediaQuery(
              data: scaledMedia,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    SizedBox(height: _kStatusBarOuterPadding * scale),
                    _BattleHeader(
                      elapsed: _elapsedVN,
                      playerName: l10n.battleYouLabel,
                      opponentName: _opponentName,
                      playerProgress: playerProgress,
                      opponentProgress: _opponentProgress,
                      playerScore: solvedCells,
                      opponentScore: _opponentSolvedCells,
                      lives: lives,
                      scale: scale,
                    ),
                    SizedBox(height: _kStatusBarOuterPadding * scale),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          topPadding,
                          0,
                          bottomPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                final targetWidth = _calculateBoardExtent(width, scale);
                                final innerPadding =
                                    math.max(0.0, (width - targetWidth) / 2);
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: innerPadding,
                                  ),
                                  child: Board(scale: scale),
                                );
                              },
                            ),
                            SizedBox(height: _kBoardToControlsSpacing * scale),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                final targetWidth =
                                    _calculateControlPanelWidth(width, scale);
                                final innerPadding =
                                    math.max(0.0, (width - targetWidth) / 2);
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: innerPadding,
                                  ),
                                  child: ControlPanel(
                                    scale: scale,
                                    compactLayout: isCompactHeight,
                                  ),
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
            );
          },
        ),
      ),
    );
  }

  void _showVictoryDialog(AppState app) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final colors = theme.extension<SudokuColors>()!;
        return Dialog(
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
                  l10n.battleVictoryTitle,
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
                          if (!context.mounted) return;
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
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          _startRematch(app);
                        },
                        child: Text(l10n.playAnother),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDefeatDialog(AppState app) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final colors = theme.extension<SudokuColors>()!;
        return Dialog(
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
                    gradient: colors.failureBadgeGradient,
                  ),
                  child: Icon(
                    Icons.flash_on,
                    color: theme.colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.battleDefeatTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.battleDefeatMessage(_opponentName),
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
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          app.loseBattle();
                          Navigator.pop(context);
                        },
                        child: Text(l10n.backToHome),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          app.loseBattle();
                          _startRematch(app);
                        },
                        child: Text(l10n.playAnother),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startRematch(AppState app) {
    final diff = widget.difficulty ?? app.currentDifficulty ?? app.featuredStatsDifficulty;
    app.startBattleGame(diff);
    app.current?.elapsedMs = 0;
    _observedSession = app.sessionId;
    _startTimer(app, 0);
    _setupOpponent(app, resetProfile: true);
    _victoryShown = false;
    _defeatShown = false;
  }
}

class _BattleHeader extends StatelessWidget {
  final ValueListenable<int> elapsed;
  final String playerName;
  final String opponentName;
  final double playerProgress;
  final double opponentProgress;
  final int playerScore;
  final int opponentScore;
  final int lives;
  final double scale;

  const _BattleHeader({
    required this.elapsed,
    required this.playerName,
    required this.opponentName,
    required this.playerProgress,
    required this.opponentProgress,
    required this.playerScore,
    required this.opponentScore,
    required this.lives,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final cs = theme.colorScheme;
    String formatScoreLabel(String name, int score) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) {
        return score.toString();
      }
      return '$trimmed ($score)';
    }

    final playerLabel = formatScoreLabel(playerName, playerScore);
    final opponentLabel = formatScoreLabel(opponentName, opponentScore);

    final nameStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: cs.onSurface,
    );
    final timerStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: cs.onSurface,
    );
    final borderRadius = BorderRadius.circular(_kBattleBannerRadius * scale);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _kBattleBannerHorizontalPadding * scale,
        vertical: _kBattleBannerVerticalPadding * scale,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 20 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: elapsed,
            builder: (_, value, __) {
              return Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatDuration(value),
                    textAlign: TextAlign.center,
                    style: timerStyle,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: _kBattleBannerTimerToLivesSpacing * scale),
          Center(child: _BattleLivesIndicator(lives: lives, scale: scale)),
          SizedBox(height: _kBattleBannerLivesToNamesSpacing * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      playerLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: nameStyle,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      opponentLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: nameStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _kBattleBannerNamesToProgressSpacing * scale),
          _BattleProgressBar(
            scale: scale,
            playerProgress: playerProgress,
            opponentProgress: opponentProgress,
            lineColor: colors.battleChallengeGradient.colors.last,
            trackColor: cs.onSurface.withOpacity(0.08),
          ),
        ],
      ),
    );
  }
}

class _BattleLivesIndicator extends StatelessWidget {
  final int lives;
  final double scale;

  const _BattleLivesIndicator({required this.lives, required this.scale});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inactive = scheme.outlineVariant;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final active = index < lives;
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : _kStatusBarHeartSpacing * scale,
            ),
            child: Icon(
              Icons.favorite,
              size: _kStatusBarHeartIconSize * scale,
              color: active ? scheme.error : inactive,
            ),
          );
        }),
      ),
    );
  }
}

class _BattleAppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double scale;

  const _BattleAppBarButton({
    required this.icon,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<SudokuColors>()!;
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

class _BattleProgressBar extends StatelessWidget {
  final double playerProgress;
  final double opponentProgress;
  final Color lineColor;
  final Color trackColor;
  final double scale;

  const _BattleProgressBar({
    required this.playerProgress,
    required this.opponentProgress,
    required this.lineColor,
    required this.trackColor,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final opponentLineColor = lineColor.withOpacity(0.7);
    final double lineThickness = _kBattleProgressBarHeight * scale;
    return ClipRRect(
      borderRadius: BorderRadius.circular(lineThickness / 2),
      child: SizedBox(
        height: lineThickness,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: trackColor),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: playerProgress.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(color: lineColor),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: opponentProgress.clamp(0.0, 1.0),
                alignment: Alignment.centerRight,
                child: Container(color: opponentLineColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const double _kGameplayUiScale = 1.1;
const double _kGameplayMinUiScale = 0.7;
const double _kGameplayHorizontalPaddingFactor = 0.025;
const double _kStatusBarOuterPadding = 10.0;
const double _kStatusBarHeartSpacing = 8.0;
const double _kStatusBarHeartIconSize = 24.0;
const double _kBattleBannerRadius = 28.0;
const double _kBattleBannerHorizontalPadding = 24.0;
const double _kBattleBannerVerticalPadding = 12.0;
const double _kBattleBannerTimerToLivesSpacing = 4.0;
const double _kBattleBannerLivesToNamesSpacing = 4.0;
const double _kBattleBannerNamesToProgressSpacing = 2.0;
const double _kBattleProgressBarHeight = 8.0;
const double _kGameContentTopPadding = 16.0;
const double _kGameContentBottomPadding = 40.0;
const double _kBoardToControlsSpacing = 8.0;
const double _kCompactHeightBreakpoint = 720.0;
const double _kTextHeightMultiplier = 1.1;

double _resolveGameplayScale({
  required double baseScale,
  required double minScale,
  required double contentWidth,
  required double availableHeight,
  required double baseTextScaleFactor,
  required ThemeData theme,
  required bool isTablet,
}) {
  if (contentWidth <= 0 || availableHeight <= 0) {
    return minScale.clamp(0.0, baseScale);
  }

  double estimate(double scale) => _estimateGameplayHeight(
        scale: scale,
        contentWidth: contentWidth,
        baseTextScaleFactor: baseTextScaleFactor,
        theme: theme,
        isTablet: isTablet,
        availableHeight: availableHeight,
      );

  final maxScaleHeight = estimate(baseScale);
  if (maxScaleHeight <= availableHeight) {
    return baseScale;
  }

  final minScaleHeight = estimate(minScale);
  if (minScaleHeight > availableHeight) {
    return minScale;
  }

  double low = minScale;
  double high = baseScale;
  double best = minScale;
  for (var i = 0; i < 18; i++) {
    final mid = (low + high) / 2;
    final height = estimate(mid);
    if (height <= availableHeight) {
      best = mid;
      low = mid;
    } else {
      high = mid;
    }
  }
  return best.clamp(minScale, baseScale);
}

double _estimateGameplayHeight({
  required double scale,
  required double contentWidth,
  required double baseTextScaleFactor,
  required ThemeData theme,
  required bool isTablet,
  required double availableHeight,
}) {
  final textScale = baseTextScaleFactor * scale;
  final headerHeight = (8.0 + 48.0) * scale;
  final statusHeight = _estimateStatusBarHeight(
    scale: scale,
    textScaleFactor: textScale,
    theme: theme,
  );
  final boardSize = _calculateBoardExtent(contentWidth, scale);
  final controlPanelWidth = _calculateControlPanelWidth(contentWidth, scale);
  final bool isCompactHeight =
      !isTablet && availableHeight < _kCompactHeightBreakpoint;
  final controlPanelHeight = estimateControlPanelHeight(
    maxWidth: controlPanelWidth,
    scale: scale,
    isTablet: isTablet,
    isCompact: isCompactHeight,
  );
  final statusPadding = _kStatusBarOuterPadding * 2 * scale;
  final topPadding = _calculateGameContentTopPadding(
    availableHeight: availableHeight,
    scale: scale,
  );
  final bottomPadding = _calculateGameContentBottomPadding(
    availableHeight: availableHeight,
    scale: scale,
  );
  final contentPadding = topPadding + bottomPadding;

  return headerHeight +
      statusPadding +
      statusHeight +
      contentPadding +
      boardSize +
      _kBoardToControlsSpacing * scale +
      controlPanelHeight;
}

double _estimateStatusBarHeight({
  required double scale,
  required double textScaleFactor,
  required ThemeData theme,
}) {
  final difficultyFont = theme.textTheme.titleMedium?.fontSize ?? 16.0;
  final difficultyHeight =
      difficultyFont * textScaleFactor * _kTextHeightMultiplier;

  final baseBadgeFont = math.max(
    theme.textTheme.titleMedium?.fontSize ?? 16,
    16,
  );
  final badgeTextHeight =
      baseBadgeFont * textScaleFactor * _kTextHeightMultiplier;
  final badgeHeight = (12 * scale) +
      math.max(24 * scale, badgeTextHeight);

  final heartsHeight = _kStatusBarHeartIconSize * scale;
  final contentHeight = math.max(
    difficultyHeight,
    math.max(badgeHeight, heartsHeight),
  );

  return (12 * scale) + contentHeight;
}

double _calculateBoardExtent(double width, double scale) {
  final baseWidth = math.max(0.0, width - 24);
  return math.min(width, baseWidth * scale);
}

double _calculateControlPanelWidth(double width, double scale) {
  final baseWidth = math.max(0.0, width - 24);
  return math.min(width, baseWidth * scale);
}

double _calculateGameContentTopPadding({
  required double availableHeight,
  required double scale,
}) {
  if (!availableHeight.isFinite || availableHeight <= 0) {
    return _kGameContentTopPadding * scale;
  }
  final double basePadding = _kGameContentTopPadding * scale;
  final double extraPadding =
      (availableHeight * 0.02).clamp(6.0, 24.0).toDouble();
  return basePadding + extraPadding;
}

double _calculateGameContentBottomPadding({
  required double availableHeight,
  required double scale,
}) {
  if (!availableHeight.isFinite || availableHeight <= 0) {
    return _kGameContentBottomPadding * scale;
  }
  final double basePadding = _kGameContentBottomPadding * scale;
  final double extraPadding =
      (availableHeight * 0.03).clamp(12.0, 36.0).toDouble();
  return basePadding + extraPadding;
}

String formatDuration(int ms) {
  final seconds = ms ~/ 1000;
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}
