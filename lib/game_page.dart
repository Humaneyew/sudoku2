import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'models.dart';
import 'settings_page.dart';
import 'widgets/board.dart';
import 'widgets/control_panel.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Timer? _timer;
  int elapsedMs = 0;
  int _observedSession = -1;
  bool _victoryShown = false;
  bool _failureShown = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        elapsedMs += 1000;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        setState(() {
          elapsedMs = 0;
        });
        _startTimer();
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
              timeText: _formatTime(elapsedMs),
              onBack: () => Navigator.pop(context),
              onRestart: () {
                final diff =
                    app.currentDifficulty ?? app.featuredStatsDifficulty;
                app.startGame(diff);
                setState(() {
                  elapsedMs = 0;
                });
                _startTimer();
              },
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      app.completeGame(elapsedMs);
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
        return Dialog(
          backgroundColor: Colors.white,
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFC26F), Color(0xFFFF8A5B)],
                    ),
                  ),
                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 36),
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
                  l10n.victoryMessage(_formatTime(elapsedMs)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6D7392),
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
                          setState(() {
                            elapsedMs = 0;
                          });
                          _startTimer();
                          _victoryShown = false;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
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
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 36),
          backgroundColor: Colors.white,
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF8095), Color(0xFFFF4D6D)],
                    ),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 40),
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
                  style: const TextStyle(
                    color: Color(0xFF6D7392),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5D7A),
                      foregroundColor: Colors.white,
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

  String _formatTime(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}

class _GameHeader extends StatelessWidget {
  final String timeText;
  final VoidCallback onBack;
  final VoidCallback onRestart;
  final VoidCallback onSettings;

  const _GameHeader({
    required this.timeText,
    required this.onBack,
    required this.onRestart,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _HeaderButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          Expanded(
            child: Column(
              children: [
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _HeaderButton(icon: Icons.pause_rounded, onTap: () {}),
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
    return InkResponse(
      radius: 28,
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x171B1D3A),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF3B82F6)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x121B1D3A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            difficulty,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD8E6FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFC26F), size: 20),
                const SizedBox(width: 6),
                Text(
                  stars.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B82F6),
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
    return Row(
      children: List.generate(3, (index) {
        final active = index < lives;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            Icons.favorite,
            size: 24,
            color: active ? const Color(0xFFE25562) : const Color(0xFFE2E5F3),
          ),
        );
      }),
    );
  }
}
