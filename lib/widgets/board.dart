import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../theme.dart';

const double _boardOuterRadiusValue = 28;
const double _boardInnerRadiusValue = 12;
const double _boardOuterPaddingValue = 10;

class Board extends StatelessWidget {
  final double scale;

  const Board({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final colors = theme.extension<SudokuColors>()!;
    final surfaceColor = cs.surface;
    final outerRadius = BorderRadius.circular(_boardOuterRadiusValue * scale);
    final innerRadius = BorderRadius.circular(_boardInnerRadiusValue * scale);
    final outerPadding = _boardOuterPaddingValue * scale;
    final shadowBlur = 24.0 * scale;
    final shadowOffset = Offset(0, 16 * scale);

    return Selector<AppState, bool>(
      selector: (_, app) => app.current != null,
      builder: (context, hasGame, _) {
        if (!hasGame) {
          return const SizedBox.shrink();
        }

        final outerDecoration = BoxDecoration(
          color: surfaceColor,
          borderRadius: outerRadius,
          boxShadow: [
            BoxShadow(
              color: colors.shadowColor,
              blurRadius: shadowBlur,
              offset: shadowOffset,
            ),
          ],
        );

        final innerDecoration = BoxDecoration(
          color: colors.boardInner,
          borderRadius: innerRadius,
        );

        return RepaintBoundary(
          key: const ValueKey('board-root'),
          child: Container(
            decoration: outerDecoration,
            padding: EdgeInsets.all(outerPadding),
            child: AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: innerDecoration,
                child: ClipRRect(
                  borderRadius: innerRadius,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.biggest;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          _BoardHighlightLayer(size: size),
                          GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 9,
                            ),
                            itemCount: 81,
                            itemBuilder: (context, index) {
                              return _BoardCell(
                                key: ValueKey('board-cell-$index'),
                                index: index,
                                scale: scale,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CellContent extends StatelessWidget {
  final int value;
  final List<int> notes;
  final bool incorrect;
  final double fontScale;
  final int valueAnimationId;

  const _CellContent({
    required this.value,
    required this.notes,
    required this.incorrect,
    required this.fontScale,
    required this.valueAnimationId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final onSurface = cs.onSurface;
    if (value != 0) {
      Widget text = AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        style: TextStyle(
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.w600,
          color: incorrect ? cs.error : onSurface,
        ),
        child: Text(value.toString()),
      );

      if (valueAnimationId != 0) {
        text = _PopBounceAnimation(
          animationId: valueAnimationId,
          child: text,
        );
      }

      return Center(child: text);
    }

    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    return _NotesGrid(
      notes: notes,
      fontScale: fontScale,
      key: ValueKey('notes-${notes.join('-')}'),
    );
  }
}

class _PopBounceAnimation extends StatelessWidget {
  static const Duration _duration = Duration(milliseconds: 320);
  static const double _minScale = 0.3;
  static const double _overshootScale = 1.2;
  static const double _finalScale = 1.0;
  static const double _firstStagePortion = 0.6;

  final Widget child;
  final int animationId;

  const _PopBounceAnimation({
    required this.child,
    required this.animationId,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('value-pop-$animationId'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: _duration,
      builder: (context, value, child) {
        final scale = _scaleForProgress(value);
        final opacity = Curves.easeOutCubic.transform(value.clamp(0.0, 1.0));
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  double _scaleForProgress(double t) {
    if (t <= 0) {
      return _minScale;
    }
    if (t >= 1) {
      return _finalScale;
    }
    if (t < _firstStagePortion) {
      final stageProgress = (t / _firstStagePortion).clamp(0.0, 1.0);
      final eased = Curves.easeOutCubic.transform(stageProgress);
      return ui.lerpDouble(_minScale, _overshootScale, eased) ?? _finalScale;
    }
    final stageProgress =
        ((t - _firstStagePortion) / (1 - _firstStagePortion)).clamp(0.0, 1.0);
    final eased = Curves.easeInOut.transform(stageProgress);
    return ui.lerpDouble(_overshootScale, _finalScale, eased) ?? _finalScale;
  }
}

class _IncorrectShakeAnimation extends StatelessWidget {
  static const Duration _duration = Duration(milliseconds: 300);
  static const double _oscillations = 3.5;

  final Widget child;
  final int animationId;
  final double scale;

  const _IncorrectShakeAnimation({
    required this.child,
    required this.animationId,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('incorrect-shake-$animationId'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: _duration,
      builder: (context, value, child) {
        final eased = Curves.easeOut.transform(value);
        final damping = math.max(0, 1 - eased);
        final amplitude = 6.0 * scale;
        final offset = math.sin(eased * math.pi * _oscillations) * amplitude * damping;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _BoardHighlightLayer extends StatelessWidget {
  final Size size;

  const _BoardHighlightLayer({required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final highlightTheme =
        theme.extension<BoardHighlightTheme>() ?? const BoardHighlightTheme(
              rowColOverlayStrength: 0.10,
              boxOverlayStrength: 0.14,
              selectedOverlayStrength: 0.20,
            );
    final boardSurface = colors.boardInner;
    final textColor = theme.colorScheme.onSurface;
    final accent = theme.colorScheme.primary;

    return IgnorePointer(
      child: Selector<AppState, _HighlightState>(
        selector: (_, app) => _HighlightState(selectedIndex: app.selectedCell),
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, highlight, _) {
          Widget child;
          if (highlight.selectedIndex == null) {
            child = SizedBox.fromSize(
              key: const ValueKey('highlight-empty'),
              size: size,
            );
          } else {
            final rowColStyle = _resolveOverlayStyle(
              boardSurface: boardSurface,
              textColor: textColor,
              targetStrength: highlightTheme.rowColOverlayStrength,
              accent: accent,
              accentBlend: 0.0,
            );
            final boxStyle = _resolveOverlayStyle(
              boardSurface: boardSurface,
              textColor: textColor,
              targetStrength: highlightTheme.boxOverlayStrength,
              accent: accent,
              accentBlend: highlightTheme.boxAccentBlend,
            );
            final selectedStyle = _resolveOverlayStyle(
              boardSurface: boardSurface,
              textColor: textColor,
              targetStrength: highlightTheme.selectedOverlayStrength,
              accent: accent,
              accentBlend: 0.0,
            );
            child = SizedBox.fromSize(
              key: ValueKey(highlight.selectedIndex),
              size: size,
              child: CustomPaint(
                painter: _BoardHighlightPainter(
                  highlight: highlight,
                  rowColStyle: rowColStyle,
                  boxStyle: boxStyle,
                  selectedStyle: selectedStyle,
                ),
              ),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 140),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: child,
          );
        },
      ),
    );
  }
}

class _BoardHighlightPainter extends CustomPainter {
  final _HighlightState highlight;
  final _OverlayStyle rowColStyle;
  final _OverlayStyle boxStyle;
  final _OverlayStyle selectedStyle;

  const _BoardHighlightPainter({
    required this.highlight,
    required this.rowColStyle,
    required this.boxStyle,
    required this.selectedStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final selectedIndex = highlight.selectedIndex;
    if (selectedIndex == null) {
      return;
    }

    final cellWidth = size.width / 9;
    final cellHeight = size.height / 9;
    final selectedRow = selectedIndex ~/ 9;
    final selectedColumn = selectedIndex % 9;

    final paths = <_OverlayStyle, Path>{};

    for (var row = 0; row < 9; row++) {
      for (var column = 0; column < 9; column++) {
        final index = row * 9 + column;
        if (index == selectedIndex) {
          continue;
        }

        _OverlayStyle? style;
        if (row == selectedRow || column == selectedColumn) {
          style = _selectDominantStyle(style, rowColStyle);
        }
        if ((row ~/ 3 == selectedRow ~/ 3) &&
            (column ~/ 3 == selectedColumn ~/ 3)) {
          style = _selectDominantStyle(style, boxStyle);
        }

        if (style == null || style.strength <= 0) {
          continue;
        }

        final rect = Rect.fromLTWH(
          column * cellWidth,
          row * cellHeight,
          cellWidth,
          cellHeight,
        );
        paths.putIfAbsent(style, Path.new).addRect(rect);
      }
    }

    for (final entry in paths.entries) {
      final paint = Paint()..color = entry.key.color;
      canvas.drawPath(entry.value, paint);
    }

    if (selectedStyle.strength > 0) {
      final rect = Rect.fromLTWH(
        selectedColumn * cellWidth,
        selectedRow * cellHeight,
        cellWidth,
        cellHeight,
      );
      final paint = Paint()..color = selectedStyle.color;
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardHighlightPainter oldDelegate) {
    return highlight != oldDelegate.highlight ||
        rowColStyle != oldDelegate.rowColStyle ||
        boxStyle != oldDelegate.boxStyle ||
        selectedStyle != oldDelegate.selectedStyle;
  }

  _OverlayStyle? _selectDominantStyle(
    _OverlayStyle? current,
    _OverlayStyle candidate,
  ) {
    if (candidate.strength <= 0) {
      return current;
    }
    if (current == null || candidate.opacity > current.opacity) {
      return candidate;
    }
    return current;
  }
}

class _HighlightState {
  final int? selectedIndex;

  const _HighlightState({required this.selectedIndex});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _HighlightState && other.selectedIndex == selectedIndex;
  }

  @override
  int get hashCode => selectedIndex.hashCode;
}

class _OverlayStyle {
  final Color color;
  final double strength;

  const _OverlayStyle({required this.color, required this.strength});

  double get opacity => color.opacity;

  static const none = _OverlayStyle(color: Color(0x00000000), strength: 0);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _OverlayStyle &&
            other.color.value == color.value &&
            other.strength == strength;
  }

  @override
  int get hashCode => Object.hash(color.value, strength);
}

const double _kContrastThreshold = 3.0;
const double _kOverlayStep = 0.02;
const double _kMinOverlayStrength = 0.06;

_OverlayStyle _resolveOverlayStyle({
  required Color boardSurface,
  required Color textColor,
  required double targetStrength,
  required Color accent,
  double accentBlend = 0.0,
}) {
  if (targetStrength <= 0) {
    return _OverlayStyle.none;
  }

  var strength = math.max(targetStrength, _kMinOverlayStrength).clamp(0.0, 1.0);
  while (true) {
    final overlay = _buildOverlayColor(
      boardSurface: boardSurface,
      strength: strength,
      accent: accent,
      accentBlend: accentBlend,
    );
    final blended = Color.alphaBlend(overlay, boardSurface);
    final contrast = _contrastRatio(textColor, blended);
    if (contrast >= _kContrastThreshold || strength <= _kMinOverlayStrength) {
      return _OverlayStyle(color: overlay, strength: strength);
    }

    final nextStrength = strength - _kOverlayStep;
    strength = nextStrength < _kMinOverlayStrength
        ? _kMinOverlayStrength
        : nextStrength;
  }
}

Color overlayFor(Color bg, double strength) {
  final isLight = bg.computeLuminance() > 0.5;
  final base = isLight ? Colors.black : Colors.white;
  return base.withOpacity(strength);
}

Color tint(Color base, Color accent, double k) {
  return Color.alphaBlend(accent.withOpacity(k), base);
}

Color _buildOverlayColor({
  required Color boardSurface,
  required double strength,
  required Color accent,
  double accentBlend = 0.0,
}) {
  var overlay = overlayFor(boardSurface, strength);
  if (accentBlend <= 0) {
    return overlay;
  }
  return _applyAccent(overlay, accent, accentBlend);
}

Color _applyAccent(Color overlay, Color accent, double amount) {
  final opacity = overlay.opacity;
  final tinted = tint(
    overlay.withOpacity(1),
    accent,
    amount.clamp(0.0, 1.0),
  );
  return tinted.withOpacity(opacity);
}

double _contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final brightest = math.max(l1, l2);
  final darkest = math.min(l1, l2);
  return (brightest + 0.05) / (darkest + 0.05);
}

class _HintHighlightOverlay extends StatelessWidget {
  static const Duration _duration = Duration(milliseconds: 900);
  static const double _fadeInPortion = 0.18;

  final int animationId;
  final Color color;
  final double scale;

  const _HintHighlightOverlay({
    required this.animationId,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('hint-highlight-$animationId'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: _duration,
      builder: (context, value, child) {
        final intensity = _intensityFor(value);
        if (intensity <= 0) {
          return const SizedBox.shrink();
        }
        final borderWidth = ui.lerpDouble(0, 3.0 * scale, intensity) ?? 0;
        final blurRadius = ui.lerpDouble(0, 26.0 * scale, intensity) ?? 0;
        final spreadRadius = ui.lerpDouble(0, 6.0 * scale, intensity) ?? 0;
        return IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0 * scale),
              border: Border.all(
                color: color.withOpacity(0.55 * intensity),
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35 * intensity),
                  blurRadius: blurRadius,
                  spreadRadius: spreadRadius,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _intensityFor(double t) {
    if (t <= 0) {
      return 0;
    }
    if (t >= 1) {
      return 0;
    }
    if (t < _fadeInPortion) {
      final progress = (t / _fadeInPortion).clamp(0.0, 1.0);
      return Curves.easeOutCubic.transform(progress);
    }
    final fadeOutProgress =
        ((t - _fadeInPortion) / (1 - _fadeInPortion)).clamp(0.0, 1.0);
    final eased = Curves.easeOutQuad.transform(fadeOutProgress);
    return (1 - eased).clamp(0.0, 1.0);
  }
}

class _NotesGrid extends StatelessWidget {
  final List<int> notes;
  final double fontScale;

  const _NotesGrid({super.key, required this.notes, required this.fontScale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Wrap(
          spacing: 4,
          runSpacing: 2,
          children: [
            for (final note in notes)
              Text(
                note.toString(),
                style: TextStyle(
                  fontSize: 10 * fontScale,
                  color: colors.noteColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Border _cellBorder(
  int index,
  double scale,
  Color thinLineColor,
  Color boldLineColor,
) {
  const thinLineWidth = 0.6;
  const boldLineWidth = 2.3;

  final scaledThinLineWidth = thinLineWidth * scale;
  final scaledBoldLineWidth = boldLineWidth * scale;

  final row = index ~/ 9;
  final col = index % 9;

  final isTopEdge = row == 0;
  final isBottomEdge = row == 8;
  final isLeftEdge = col == 0;
  final isRightEdge = col == 8;

  final showTop = !isTopEdge && row % 3 != 0;
  final showLeft = !isLeftEdge && col % 3 != 0;
  final showRight = !isRightEdge && (col + 1) % 3 == 0;
  final showBottom = !isBottomEdge && (row + 1) % 3 == 0;

  BorderSide buildSide({required bool bold}) => BorderSide(
        color: bold ? boldLineColor : thinLineColor,
        width: bold ? scaledBoldLineWidth : scaledThinLineWidth,
      );

  return Border(
    top: showTop ? buildSide(bold: false) : BorderSide.none,
    left: showLeft ? buildSide(bold: false) : BorderSide.none,
    right: showRight ? buildSide(bold: true) : BorderSide.none,
    bottom: showBottom ? buildSide(bold: true) : BorderSide.none,
  );
}

class _BoardCell extends StatelessWidget {
  final int index;
  final double scale;

  const _BoardCell({super.key, required this.index, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, _CellState?>(
      selector: (_, app) {
        final game = app.current;
        if (game == null) {
          return null;
        }
        final value = game.board[index];
        final notesSet = game.notes[index];
        final notes = notesSet.isEmpty
            ? const <int>[]
            : List<int>.unmodifiable(List<int>.from(notesSet)..sort());
        final fixed = game.given[index] || game.locked[index];
        final selected = app.selectedCell;
        final isSelected = selected == index;
        final sameValue = app.isSameAsSelectedValue(index);
        final incorrect =
            !fixed && value != 0 && !app.isMoveValid(index, value);
        final hintHighlightId = app.hintHighlightIdForCell(index);
        final valueAnimationId = app.valueAnimationIdForCell(index);
        final incorrectAnimationId = app.incorrectAnimationIdForCell(index);
        return _CellState(
          value: value,
          notes: notes,
          isSelected: isSelected,
          sameValue: sameValue,
          incorrect: incorrect,
          fontScale: app.fontScale,
          hintHighlightId: hintHighlightId,
          valueAnimationId: valueAnimationId,
          incorrectAnimationId: incorrectAnimationId,
        );
      },
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, cell, _) {
        if (cell == null) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final colors = theme.extension<SudokuColors>()!;
        final baseInner = colors.boardInner;
        final thinColor = Color.alphaBlend(
          cs.onSurface.withOpacity(0.18),
          baseInner,
        );
        final boldColor = Color.alphaBlend(
          cs.onSurface.withOpacity(0.85),
          baseInner,
        );
        final border = _cellBorder(index, scale, thinColor, boldColor);
        final highlightSameValue =
            cell.value != 0 && cell.sameValue && !cell.isSelected;
        final sameNumberBackground =
            Color.alphaBlend(colors.sameNumberCell, baseInner);
        final backgroundColor =
            highlightSameValue ? sameNumberBackground : null;

        Widget content = Stack(
            fit: StackFit.expand,
            children: [
              if (cell.hintHighlightId != 0)
                Positioned.fill(
                  child: _HintHighlightOverlay(
                    animationId: cell.hintHighlightId,
                    color: colors.hintHighlight,
                    scale: scale,
                  ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: border,
                ),
                child: _CellContent(
                  value: cell.value,
                  notes: cell.notes,
                  incorrect: cell.incorrect,
                  fontScale: cell.fontScale,
                  valueAnimationId: cell.valueAnimationId,
                ),
              ),
            ],
          );

        if (cell.incorrectAnimationId != 0) {
          content = _IncorrectShakeAnimation(
            animationId: cell.incorrectAnimationId,
            scale: scale,
            child: content,
          );
        }

        return GestureDetector(
          onTap: () => context.read<AppState>().selectCell(index),
          child: content,
        );
      },
    );
  }
}

class _CellState {
  final int value;
  final List<int> notes;
  final bool isSelected;
  final bool sameValue;
  final bool incorrect;
  final double fontScale;
  final int hintHighlightId;
  final int valueAnimationId;
  final int incorrectAnimationId;

  const _CellState({
    required this.value,
    required this.notes,
    required this.isSelected,
    required this.sameValue,
    required this.incorrect,
    required this.fontScale,
    required this.hintHighlightId,
    required this.valueAnimationId,
    required this.incorrectAnimationId,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _CellState &&
            other.value == value &&
            listEquals(other.notes, notes) &&
            other.isSelected == isSelected &&
            other.sameValue == sameValue &&
            other.incorrect == incorrect &&
            other.fontScale == fontScale &&
            other.hintHighlightId == hintHighlightId &&
            other.valueAnimationId == valueAnimationId &&
            other.incorrectAnimationId == incorrectAnimationId;
  }

  @override
  int get hashCode => Object.hash(
        value,
        Object.hashAll(notes),
        isSelected,
        sameValue,
        incorrect,
        fontScale,
        hintHighlightId,
        valueAnimationId,
        incorrectAnimationId,
      );
}
