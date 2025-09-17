import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';

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

    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;

    return Consumer<AppState>(
      builder: (context, app, _) {
        final game = app.current;
        if (game == null) {
          return const SizedBox.shrink();
        }

        _syncWithApp(app, reduceMotion);

        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
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

class _BoardCell extends StatelessWidget {
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
    required this.onTap,
  });

  bool get _hasCorrectEntry => value != 0 && !given && !incorrect;

  @override
  Widget build(BuildContext context) {
    const correctEntryColor = Color(0xFFE8F0FF);
    const selectionBorderColor = Color(0xFFCBD5E1);
    const candidateHighlightColor = Color(0x112563EB);
    const peerHighlightColor = Color(0x0C1F2937);
    const sameValueHighlightColor = Color(0x152563EB);
    const conflictHighlightColor = Color(0x1AE25562);

    final border = _cellBorder(index);
    final baseColor = _hasCorrectEntry ? correctEntryColor : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          border: border,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (highlightCandidate)
              const _HighlightLayer(color: candidateHighlightColor),
            if (isPeer) const _HighlightLayer(color: peerHighlightColor),
            if (sameValue)
              const _HighlightLayer(color: sameValueHighlightColor),
            if (conflict)
              const _HighlightLayer(color: conflictHighlightColor),
            if (victoryIntensity > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: victoryIntensity * 0.6,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF4CC),
                      ),
                    ),
                  ),
                ),
              ),
            Center(
              child: _CellContent(
                value: value,
                notes: notes,
                given: given,
                incorrect: incorrect,
              ),
            ),
            if (isSelected)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectionBorderColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HighlightLayer extends StatelessWidget {
  final Color color;

  const _HighlightLayer({required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(color: color),
        ),
      ),
    );
  }
}

class _CellContent extends StatelessWidget {
  final int value;
  final Set<int> notes;
  final bool given;
  final bool incorrect;

  const _CellContent({
    required this.value,
    required this.notes,
    required this.given,
    required this.incorrect,
  });

  @override
  Widget build(BuildContext context) {
    if (value != 0) {
      return Text(
        value.toString(),
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
    }

    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = notes.toList()..sort();
    return _NotesGrid(
      notes: notes,
      key: ValueKey('notes-${sorted.join('-')}'),
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
  const thinLineColor = Color(0xFFD1D5DB);
  const boldLineColor = Color(0xFF9CA3AF);
  const thinLineWidth = 0.5;
  const boldLineWidth = 1.2;

  final row = index ~/ 9;
  final col = index % 9;

  final topIsBold = row % 3 == 0;
  final leftIsBold = col % 3 == 0;
  final rightIsBold = col == 8;
  final bottomIsBold = row == 8;

  return Border(
    top: BorderSide(
      color: topIsBold ? boldLineColor : thinLineColor,
      width: topIsBold ? boldLineWidth : thinLineWidth,
    ),
    left: BorderSide(
      color: leftIsBold ? boldLineColor : thinLineColor,
      width: leftIsBold ? boldLineWidth : thinLineWidth,
    ),
    right: BorderSide(
      color: rightIsBold ? boldLineColor : thinLineColor,
      width: rightIsBold ? boldLineWidth : thinLineWidth,
    ),
    bottom: BorderSide(
      color: bottomIsBold ? boldLineColor : thinLineColor,
      width: bottomIsBold ? boldLineWidth : thinLineWidth,
    ),
  );
}
