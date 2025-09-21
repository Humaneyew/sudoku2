import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../theme.dart';

const double _boardOuterRadiusValue = 28;
const double _boardInnerRadiusValue = 12;

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
    final outerPadding = 16.0 * scale;
    final borderWidth = 4.0 * scale;
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
          border: Border.all(color: colors.boardBorder, width: borderWidth),
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
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                    ),
                    itemCount: 81,
                    itemBuilder: (context, index) {
                      return _BoardCell(
                        key: ValueKey('board-cell-$index'),
                        index: index,
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
  const thinLineWidth = 0.6;
  const boldLineWidth = 2.3;

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
        width: bold ? boldLineWidth : thinLineWidth,
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

  const _BoardCell({super.key, required this.index});

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
        final selected = app.selectedCell;
        final isSelected = selected == index;
        final row = index ~/ 9;
        final column = index % 9;
        final selectedRow = selected != null ? selected ~/ 9 : null;
        final selectedColumn = selected != null ? selected % 9 : null;
        final sameRow = selectedRow != null && selectedRow == row;
        final sameColumn =
            selectedColumn != null && selectedColumn == column;
        final sameBlock = selectedRow != null &&
            selectedColumn != null &&
            (selectedRow ~/ 3) == (row ~/ 3) &&
            (selectedColumn ~/ 3) == (column ~/ 3);
        final sameValue = app.isSameAsSelectedValue(index);
        final incorrect =
            !given && value != 0 && !app.isMoveValid(index, value);
        return _CellState(
          value: value,
          notes: notes,
          isSelected: isSelected,
          sameRow: sameRow,
          sameColumn: sameColumn,
          sameBlock: sameBlock,
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
          cs.onSurface.withOpacity(0.18),
          baseInner,
        );
        final boldColor = Color.alphaBlend(
          cs.onSurface.withOpacity(0.85),
          baseInner,
        );
        final border = _cellBorder(index, thinColor, boldColor);
        final highlightSameValue =
            cell.value != 0 && cell.sameValue && !cell.isSelected;
        final highlightBlock = cell.sameBlock && !cell.isSelected;
        final highlightCrosshair =
            (cell.sameRow || cell.sameColumn) && !cell.isSelected;
        final selectedBackground = colors.selectedCell;
        final sameNumberBackground =
            Color.alphaBlend(colors.sameNumberCell, baseInner);
        final blockBackground =
            Color.alphaBlend(colors.blockHighlight, baseInner);
        final crosshairBackground =
            Color.alphaBlend(colors.crosshairHighlight, baseInner);
        final backgroundColor = cell.isSelected
            ? selectedBackground
            : highlightSameValue
                ? sameNumberBackground
                : highlightBlock
                    ? blockBackground
                    : highlightCrosshair
                        ? crosshairBackground
                        : baseInner;

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
  final bool sameRow;
  final bool sameColumn;
  final bool sameBlock;
  final bool sameValue;
  final bool incorrect;
  final double fontScale;

  const _CellState({
    required this.value,
    required this.notes,
    required this.isSelected,
    required this.sameRow,
    required this.sameColumn,
    required this.sameBlock,
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
            other.sameRow == sameRow &&
            other.sameColumn == sameColumn &&
            other.sameBlock == sameBlock &&
            other.sameValue == sameValue &&
            other.incorrect == incorrect &&
            other.fontScale == fontScale;
  }

  @override
  int get hashCode => Object.hash(
        value,
        Object.hashAll(notes),
        isSelected,
        sameRow,
        sameColumn,
        sameBlock,
        sameValue,
        incorrect,
        fontScale,
      );
}
