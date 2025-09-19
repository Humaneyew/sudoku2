import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../theme.dart';

const BorderRadius _boardOuterRadius = BorderRadius.all(Radius.circular(28));
const BorderRadius _boardInnerRadius = BorderRadius.all(Radius.circular(12));

class Board extends StatelessWidget {
  const Board({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final colors = theme.extension<SudokuColors>()!;
    final surfaceColor = cs.surface;

    return Selector<AppState, bool>(
      selector: (_, app) => app.current != null,
      builder: (context, hasGame, _) {
        if (!hasGame) {
          return const SizedBox.shrink();
        }

        final outerDecoration = BoxDecoration(
          color: surfaceColor,
          borderRadius: _boardOuterRadius,
          boxShadow: [
            BoxShadow(
              color: colors.shadowColor,
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        );

        final innerDecoration = BoxDecoration(
          color: colors.boardInner,
          borderRadius: _boardInnerRadius,
          border: Border.all(color: colors.boardBorder, width: 4),
        );

        return RepaintBoundary(
          key: const ValueKey('board-root'),
          child: Container(
            decoration: outerDecoration,
            padding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: innerDecoration,
                child: ClipRRect(
                  borderRadius: _boardInnerRadius,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                    ),
                    itemCount: 81,
                    itemBuilder: (context, index) {
                      return _BoardCell(index: index);
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

  const _CellContent({
    required this.value,
    required this.notes,
    required this.incorrect,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final colors = theme.extension<SudokuColors>()!;
    final onSurface = cs.onSurface;
    if (value != 0) {
      return Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          style: TextStyle(
            fontSize: 20 * fontScale,
            fontWeight: FontWeight.w600,
            color: incorrect ? cs.error : onSurface,
          ),
          child: Text(value.toString()),
        ),
      );
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

Border _cellBorder(int index, Color thinLineColor, Color boldLineColor) {
  const thinLineWidth = 0.5;
  const boldLineWidth = 1.6;

  final row = index ~/ 9;
  final col = index % 9;

  final isTopEdge = row == 0;
  final isLeftEdge = col == 0;
  final topIsBold = row % 3 == 0;
  final leftIsBold = col % 3 == 0;

  return Border(
    top: isTopEdge
        ? BorderSide.none
        : BorderSide(
            color: topIsBold ? boldLineColor : thinLineColor,
            width: topIsBold ? boldLineWidth : thinLineWidth,
          ),
    left: isLeftEdge
        ? BorderSide.none
        : BorderSide(
            color: leftIsBold ? boldLineColor : thinLineColor,
            width: leftIsBold ? boldLineWidth : thinLineWidth,
          ),
    right: BorderSide.none,
    bottom: BorderSide.none,
  );
}

class _BoardCell extends StatelessWidget {
  final int index;

  const _BoardCell({required this.index})
      : super(key: ValueKey('board-cell-$index'));

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
        final given = game.given[index];
        final isSelected = app.selectedCell == index;
        final sameValue = app.isSameAsSelectedValue(index);
        final incorrect =
            !given && value != 0 && !app.isMoveValid(index, value);
        return _CellState(
          value: value,
          notes: notes,
          isSelected: isSelected,
          sameValue: sameValue,
          incorrect: incorrect,
          fontScale: app.fontScale,
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
          cs.onSurface.withOpacity(0.08),
          baseInner,
        );
        final boldColor = Color.alphaBlend(
          cs.onSurface.withOpacity(0.18),
          baseInner,
        );
        final border = _cellBorder(index, thinColor, boldColor);
        final highlightSameValue =
            cell.value != 0 && cell.sameValue && !cell.isSelected;
        final backgroundColor = cell.isSelected
            ? colors.selectedCell
            : highlightSameValue
                ? colors.sameNumberCell
                : colors.boardInner;

        return GestureDetector(
          onTap: () => context.read<AppState>().selectCell(index),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: border,
            ),
            child: _CellContent(
              value: cell.value,
              notes: cell.notes,
              incorrect: cell.incorrect,
              fontScale: cell.fontScale,
            ),
          ),
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

  const _CellState({
    required this.value,
    required this.notes,
    required this.isSelected,
    required this.sameValue,
    required this.incorrect,
    required this.fontScale,
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
            other.fontScale == fontScale;
  }

  @override
  int get hashCode => Object.hash(
        value,
        Object.hashAll(notes),
        isSelected,
        sameValue,
        incorrect,
        fontScale,
      );
}
