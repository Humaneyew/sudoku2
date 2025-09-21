import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

enum _OpponentPhase { normal, pause, burst }

class _BattlePageState extends State<BattlePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final ValueNotifier<int> _elapsedVN = ValueNotifier<int>(0);
  Timer? _timer;
  Ticker? _opponentTicker;
  AnimationController? _pulseController;

  AppState? _appState;
  late final VoidCallback _appStateListener;

  bool _victoryShown = false;
  bool _defeatShown = false;
  bool _opponentFinished = false;
  int _observedSession = -1;

  final math.Random _random = math.Random();

  String _opponentName = '';
  String _opponentFlag = '🏳️';

  double _opponentProgress = 0;
  double _initialProgress = 0;
  double _baseSpeed = 0.02; // progress per second
  double _currentSpeedMultiplier = 1.0;
  Duration _phaseEnd = Duration.zero;
  Duration _lastTick = Duration.zero;
  _OpponentPhase _phase = _OpponentPhase.normal;

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
    final selected = await showFlagPicker(context);
    if (selected != null && selected.isNotEmpty) {
      app.setPlayerFlag(selected);
    } else if (app.playerFlag == null || app.playerFlag!.isEmpty) {
      app.setPlayerFlag(kWorldFlags.first);
    }
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
      _opponentFlag = randomFlag(random: _random, exclude: app.playerFlag);
    }

    final initialProgress = _calculateProgress(game);
    setState(() {
      _initialProgress = initialProgress;
      _opponentProgress = initialProgress;
      _opponentFinished = false;
      _defeatShown = false;
    });

    final durationSeconds = _estimateOpponentDurationSeconds(app);
    final remaining = (1.0 - _initialProgress).clamp(0.05, 1.0);
    _baseSpeed = durationSeconds <= 0 ? remaining / 300 : remaining / durationSeconds;
    _currentSpeedMultiplier = 1.0;
    _phaseEnd = Duration.zero;
    _lastTick = Duration.zero;

    _opponentTicker?.dispose();
    _opponentTicker = createTicker(_handleOpponentTick)..start();

    _pulseController?.dispose();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  void _handleOpponentTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMilliseconds / 1000.0;
    _lastTick = elapsed;
    if (dt <= 0 || _opponentFinished) {
      return;
    }

    if (elapsed >= _phaseEnd) {
      _startNextPhase(elapsed);
    }

    final progressDelta = _baseSpeed * _currentSpeedMultiplier * dt;
    if (progressDelta > 0) {
      if (!mounted) {
        _opponentTicker?.stop();
        return;
      }
      setState(() {
        _opponentProgress = (_opponentProgress + progressDelta).clamp(0.0, 1.0);
      });
    }

    if (_opponentProgress >= 0.999 && !_opponentFinished) {
      _opponentFinished = true;
      _opponentProgress = 1.0;
      _opponentTicker?.stop();
      _scheduleHandleGameState();
    }
  }

  void _startNextPhase(Duration elapsed) {
    final roll = _random.nextDouble();
    if (roll < 0.15) {
      _phase = _OpponentPhase.pause;
      _currentSpeedMultiplier = 0.0;
      final pauseMs = 600 + _random.nextInt(1400);
      _phaseEnd = elapsed + Duration(milliseconds: pauseMs);
    } else if (roll < 0.28) {
      _phase = _OpponentPhase.burst;
      _currentSpeedMultiplier = 1.8 + _random.nextDouble() * 1.4;
      final burstMs = 800 + _random.nextInt(1400);
      _phaseEnd = elapsed + Duration(milliseconds: burstMs);
    } else {
      _phase = _OpponentPhase.normal;
      _currentSpeedMultiplier = 0.85 + _random.nextDouble() * 0.5;
      final spanMs = 1500 + _random.nextInt(2500);
      _phaseEnd = elapsed + Duration(milliseconds: spanMs);
    }
  }

  double _calculateProgress(GameState game) {
    final solved = _countSolvedCells(game);
    return solved / game.board.length;
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

  int _estimateOpponentDurationSeconds(AppState app) {
    final diff = app.currentDifficulty ?? app.featuredStatsDifficulty;
    final stats = app.statsFor(diff);
    int averageMs;
    if (stats.winsWithTime > 0) {
      averageMs = stats.totalTimeMs ~/ math.max(1, stats.winsWithTime);
    } else {
      averageMs = 8 * 60 * 1000;
    }
    averageMs = averageMs.clamp(4 * 60 * 1000, 18 * 60 * 1000);
    final factor = 0.7 + _random.nextDouble() * 0.6;
    return (averageMs * factor / 1000).round();
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
      _pulseController?.stop();
      if (!_victoryShown) {
        _victoryShown = true;
        _showVictoryDialog(app);
      }
      return;
    }

    if (_opponentFinished && !app.isSolved && !_defeatShown) {
      _defeatShown = true;
      _opponentTicker?.stop();
      _pulseController?.stop();
      _showDefeatDialog(app);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _opponentTicker?.dispose();
    _pulseController?.dispose();

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.battleTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => showThemeMenu(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
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

            return MediaQuery(
              data: scaledMedia,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    _BattleHeader(
                      elapsed: _elapsedVN,
                      playerFlag: app.playerFlag ?? '🏳️',
                      opponentFlag: _opponentFlag,
                      playerName: l10n.battleYouLabel,
                      opponentName: _opponentName,
                      playerProgress: playerProgress,
                      opponentProgress: _opponentProgress,
                      pulseController: _pulseController,
                      solvedCells: solvedCells,
                      totalCells: game.board.length,
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
  final String playerFlag;
  final String opponentFlag;
  final String playerName;
  final String opponentName;
  final double playerProgress;
  final double opponentProgress;
  final AnimationController? pulseController;
  final int solvedCells;
  final int totalCells;

  const _BattleHeader({
    required this.elapsed,
    required this.playerFlag,
    required this.opponentFlag,
    required this.playerName,
    required this.opponentName,
    required this.playerProgress,
    required this.opponentProgress,
    required this.pulseController,
    required this.solvedCells,
    required this.totalCells,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final colors = theme.extension<SudokuColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: elapsed,
          builder: (_, value, __) {
            return Text(
              formatDuration(value),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _ProgressBar(
          label: playerName,
          flag: playerFlag,
          value: playerProgress,
          color: cs.primary,
          background: cs.primary.withOpacity(0.12),
          valueText: '$solvedCells / $totalCells',
          pulse: null,
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: pulseController ?? const AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            final t = pulseController?.value ?? 0.0;
            final pulseColor = Color.lerp(
              colors.battleChallengeGradient.colors.first,
              colors.battleChallengeGradient.colors.last,
              0.5 + (math.sin(t * math.pi) * 0.5),
            );
            return _ProgressBar(
              label: opponentName,
              flag: opponentFlag,
              value: opponentProgress,
              color: pulseColor ?? cs.secondary,
              background: (pulseColor ?? cs.secondary).withOpacity(0.16),
              valueText: '${(opponentProgress * 100).clamp(0, 100).round()}%',
              pulse: true,
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _FlagAvatar(flag: playerFlag, label: playerName),
            const Spacer(),
            _FlagAvatar(flag: opponentFlag, label: opponentName),
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final String flag;
  final double value;
  final Color color;
  final Color background;
  final String valueText;
  final bool? pulse;

  const _ProgressBar({
    required this.label,
    required this.flag,
    required this.value,
    required this.color,
    required this.background,
    required this.valueText,
    this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$flag $label',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              valueText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: background,
                ),
              ),
              FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: pulse == true
                        ? LinearGradient(
                            colors: [
                              color.withOpacity(0.8),
                              color,
                            ],
                          )
                        : null,
                    color: pulse == true ? null : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlagAvatar extends StatelessWidget {
  final String flag;
  final String label;

  const _FlagAvatar({required this.flag, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.4),
            shape: BoxShape.circle,
            border: Border.all(color: cs.primary.withOpacity(0.2)),
          ),
          alignment: Alignment.center,
          child: Text(
            flag,
            style: const TextStyle(fontSize: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

const double _kGameplayUiScale = 1.1;
const double _kGameplayMinUiScale = 0.7;
const double _kGameplayHorizontalPaddingFactor = 0.025;
const double _kStatusBarOuterPadding = 10.0;
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

  final heartsHeight = 24 * scale;
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
