import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';

const _kHighlightDuration = Duration(milliseconds: 150);

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with TickerProviderStateMixin {
  late final AnimationController _victoryController;
  late final AnimationController _defeatOverlayController;
  late final AnimationController _defeatShakeController;
  late final Animation<double> _defeatOverlayAnimation;
  late final Listenable _boardAnimations;

  int _observedSession = -1;
  bool _wasCompleted = false;
  bool _wasOutOfLives = false;
  bool _lastReduceMotion = false;

  @override
  void initState() {
    super.initState();
    _victoryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _victoryController.reset();
        }
      });

    _defeatOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _defeatShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _defeatOverlayAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.65).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.65),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.65, end: 0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 40,
      ),
    ]).animate(_defeatOverlayController);

    _boardAnimations = Listenable.merge([
      _victoryController,
      _defeatOverlayController,
      _defeatShakeController,
    ]);
  }

  @override
  void dispose() {
    _victoryController.dispose();
    _defeatOverlayController.dispose();
    _defeatShakeController.dispose();
    super.dispose();
  }

  void _syncWithApp(AppState app, bool reduceMotion) {
    if (_observedSession != app.sessionId) {
      _observedSession = app.sessionId;
      _victoryController.reset();
      _defeatOverlayController.reset();
      _defeatShakeController.reset();
      _wasCompleted = false;
      _wasOutOfLives = false;
    }

    if (reduceMotion) {
      if (!_lastReduceMotion) {
        _victoryController.reset();
        _defeatOverlayController.reset();
        _defeatShakeController.reset();
      }
    }

    if (app.gameCompleted && !_wasCompleted) {
      _wasCompleted = true;
      if (!reduceMotion) {
        _victoryController.forward(from: 0);
      }
    } else if (!app.gameCompleted) {
      _wasCompleted = false;
    }

    if (app.isOutOfLives) {
      if (!_wasOutOfLives) {
        _wasOutOfLives = true;
        if (!reduceMotion) {
          _defeatOverlayController.forward(from: 0);
          _defeatShakeController.forward(from: 0);
        }
      }
    } else {
      if (_wasOutOfLives) {
        _defeatOverlayController.reset();
        _defeatShakeController.reset();
      }
      _wasOutOfLives = false;
    }

    _lastReduceMotion = reduceMotion;
  }

  double _rowVictoryIntensity(int row, double progress) {
    if (progress == 0) return 0;
    final wave = progress * 10 - 0.5;
    final distance = (wave - row).abs();
    if (distance >= 1.5) return 0;
    return (1.5 - distance) / 1.5;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Consumer<AppState>(
      builder: (context, app, _) {
        final game = app.current;
        if (game == null) {
          return const SizedBox.shrink();
        }

        _syncWithApp(app, reduceMotion);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x141B1D3A),
                blurRadius: 24,
                offset: Offset(0, 16),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AnimatedBuilder(
                animation: _boardAnimations,
                builder: (context, _) {
                  final shakeOffset = reduceMotion
                      ? 0.0
                      : math.sin(_defeatShakeController.value * math.pi * 4) *
                          6 *
                          (1 - _defeatShakeController.value);
                  final overlayOpacity =
                      reduceMotion ? 0.0 : _defeatOverlayAnimation.value;
                  final victoryProgress =
                      reduceMotion ? 0.0 : _victoryController.value;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.translate(
                        offset: Offset(shakeOffset, 0),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 9,
                          ),
                          itemCount: 81,
                          itemBuilder: (context, index) {
                            final value = game.board[index];
                            final notes = game.notes[index];
                            final given = game.given[index];
                            final isSelected = app.selectedCell == index;
                            final isPeer = app.isPeerOfSelected(index);
                            final sameValue =
                                app.isSameAsSelectedValue(index);
                            final conflict = app.hasConflict(index);
                            final incorrect = !given &&
                                value != 0 &&
                                !app.isMoveValid(index, value);
                            final highlightCandidate =
                                app.isHighlightedCandidate(index);
                            final row = index ~/ 9;
                            final victoryIntensity =
                                _rowVictoryIntensity(row, victoryProgress);

                            return _BoardCell(
                              index: index,
                              value: value,
                              notes: notes,
                              given: given,
                              isSelected: isSelected,
                              isPeer: isPeer,
                              sameValue: sameValue,
                              conflict: conflict,
                              incorrect: incorrect,
                              highlightCandidate: highlightCandidate,
                              victoryIntensity: victoryIntensity,
                              reduceMotion: reduceMotion,
                              onTap: () => app.selectCell(index),
                            );
                          },
                        ),
                      ),
                      if (!reduceMotion && overlayOpacity > 0)
                        IgnorePointer(
                          child: Container(
                            color: const Color(0xFFFFA7B5)
                                .withOpacity(overlayOpacity),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BoardCell extends StatefulWidget {
  final int index;
  final int value;
  final Set<int> notes;
  final bool given;
  final bool isSelected;
  final bool isPeer;
  final bool sameValue;
  final bool conflict;
  final bool incorrect;
  final bool highlightCandidate;
  final double victoryIntensity;
  final bool reduceMotion;
  final VoidCallback onTap;

  const _BoardCell({
    required this.index,
    required this.value,
    required this.notes,
    required this.given,
    required this.isSelected,
    required this.isPeer,
    required this.sameValue,
    required this.conflict,
    required this.incorrect,
    required this.highlightCandidate,
    required this.victoryIntensity,
    required this.reduceMotion,
    required this.onTap,
  });

  @override
  State<_BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<_BoardCell> with TickerProviderStateMixin {
  late final AnimationController _correctController;
  late final AnimationController _shakeController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;
  late final Listenable _animations;

  @override
  void initState() {
    super.initState();
    _correctController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.12).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 45,
      ),
    ]).animate(_correctController);
    _glowAnimation = CurvedAnimation(
      parent: _correctController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ).drive(Tween<double>(begin: 0.5, end: 0.0));

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _animations = Listenable.merge([
      _correctController,
      _shakeController,
    ]);
  }

  @override
  void dispose() {
    _correctController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _BoardCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion) {
      if (_correctController.isAnimating) {
        _correctController.stop();
      }
      if (_shakeController.isAnimating) {
        _shakeController.stop();
      }
      return;
    }

    if (widget.value != oldWidget.value) {
      _correctController.stop();
      _shakeController.stop();

      if (widget.value != 0 && !widget.given) {
        if (widget.incorrect) {
          _shakeController.forward(from: 0);
        } else {
          _correctController.forward(from: 0);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = _cellBorder(widget.index);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animations,
        builder: (context, child) {
          final scale = widget.reduceMotion || widget.value == 0
              ? 1.0
              : _scaleAnimation.value;
          final shakeOffset = widget.reduceMotion
              ? 0.0
              : math.sin(_shakeController.value * math.pi * 4) *
                  5 *
                  (1 - _shakeController.value);
          final glowOpacity =
              widget.reduceMotion ? 0.0 : _glowAnimation.value;

          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: border,
                  ),
                ),
                _HighlightLayer(
                  active: widget.highlightCandidate,
                  color: const Color(0xFFE8F2FF),
                  reduceMotion: widget.reduceMotion,
                ),
                _HighlightLayer(
                  active: widget.isPeer,
                  color: const Color(0xFFF2F5FF),
                  reduceMotion: widget.reduceMotion,
                ),
                _HighlightLayer(
                  active: widget.sameValue,
                  color: const Color(0xFFDAE8FF),
                  reduceMotion: widget.reduceMotion,
                ),
                _HighlightLayer(
                  active: widget.isSelected,
                  color: const Color(0xFFC7DBFF),
                  reduceMotion: widget.reduceMotion,
                ),
                _HighlightLayer(
                  active: widget.conflict,
                  color: const Color(0xFFFFE4E8),
                  reduceMotion: widget.reduceMotion,
                ),
                if (widget.victoryIntensity > 0)
                  Positioned.fill(
                    child: Opacity(
                      opacity: widget.victoryIntensity * 0.6,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF4CC),
                        ),
                      ),
                    ),
                  ),
                if (!widget.reduceMotion && glowOpacity > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.8,
                            colors: [
                              const Color(0x663B82F6)
                                  .withOpacity(glowOpacity),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                ),
              ],
            ),
          );
        },
        child: _AnimatedCellContent(
          value: widget.value,
          notes: widget.notes,
          given: widget.given,
          incorrect: widget.incorrect,
          reduceMotion: widget.reduceMotion,
        ),
      ),
    );
  }
}

class _HighlightLayer extends StatelessWidget {
  final bool active;
  final Color color;
  final bool reduceMotion;

  const _HighlightLayer({
    required this.active,
    required this.color,
    required this.reduceMotion,
  });

  @override
  Widget build(BuildContext context) {
    final box = DecoratedBox(
      decoration: BoxDecoration(color: color),
    );

    if (reduceMotion) {
      if (!active) {
        return const SizedBox.shrink();
      }
      return Positioned.fill(child: box);
    }

    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: active ? 1 : 0,
        duration: _kHighlightDuration,
        curve: Curves.easeOut,
        child: box,
      ),
    );
  }
}

class _AnimatedCellContent extends StatelessWidget {
  final int value;
  final Set<int> notes;
  final bool given;
  final bool incorrect;
  final bool reduceMotion;

  const _AnimatedCellContent({
    required this.value,
    required this.notes,
    required this.given,
    required this.incorrect,
    required this.reduceMotion,
  });

  @override
  Widget build(BuildContext context) {
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 150);

    Widget child;
    if (value != 0) {
      child = Text(
        value.toString(),
        key: ValueKey('value-$value-${given ? 1 : 0}-${incorrect ? 1 : 0}'),
        style: TextStyle(
          fontSize: 22,
          fontWeight: given ? FontWeight.w700 : FontWeight.w600,
          color: incorrect
              ? const Color(0xFFE25562)
              : (given
                  ? const Color(0xFF1F2437)
                  : const Color(0xFF2563EB)),
        ),
      );
    } else if (notes.isEmpty) {
      child = const SizedBox(key: ValueKey('empty'));
    } else {
      final sorted = notes.toList()..sort();
      child = _NotesGrid(
        notes: notes,
        key: ValueKey('notes-${sorted.join('-')}'),
      );
    }

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        if (reduceMotion) {
          return child;
        }
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}

class _NotesGrid extends StatelessWidget {
  final Set<int> notes;

  const _NotesGrid({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 2,
        children: [
          for (var i = 1; i <= 9; i++)
            SizedBox(
              width: 14,
              child: Text(
                notes.contains(i) ? i.toString() : '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF96A0C4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Border _cellBorder(int index) {
  final row = index ~/ 9;
  final col = index % 9;

  return Border(
    top: BorderSide(
      color: const Color(0xFFB4C1E0),
      width: row % 3 == 0 ? 1.6 : 0.5,
    ),
    left: BorderSide(
      color: const Color(0xFFB4C1E0),
      width: col % 3 == 0 ? 1.6 : 0.5,
    ),
    right: BorderSide(
      color: const Color(0xFFB4C1E0),
      width: col == 8 ? 1.6 : 0.5,
    ),
    bottom: BorderSide(
      color: const Color(0xFFB4C1E0),
      width: row == 8 ? 1.6 : 0.5,
    ),
  );
}
