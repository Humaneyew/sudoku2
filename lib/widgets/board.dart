import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../theme.dart';

class Board extends StatelessWidget {
  const Board({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final surfaceColor = theme.colorScheme.surface;

    return Consumer<AppState>(
      builder: (context, app, _) {
        final game = app.current;
        if (game == null) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          key: const ValueKey('board-root'),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: colors.shadowColor,
                  blurRadius: 24,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.boardInner,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.boardBorder, width: 4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                    ),
                    itemCount: 81,
                    itemBuilder: (context, index) {
                      final value = game.board[index];
                      final notes = game.notes[index];
                      final given = game.given[index];
                      final isSelected = app.selectedCell == index;
                      final sameValue = app.isSameAsSelectedValue(index);
                      final incorrect =
                          !given && value != 0 && !app.isMoveValid(index, value);

                      return _BoardCell(
                        index: index,
                        value: value,
                        notes: notes,
                        isSelected: isSelected,
                        sameValue: sameValue,
                        incorrect: incorrect,
                        fontScale: app.fontScale,
                        onTap: () => app.selectCell(index),
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

class _BoardCell extends StatelessWidget {
  final int index;
  final int value;
  final Set<int> notes;
  final bool isSelected;
  final bool sameValue;
  final bool incorrect;
  final double fontScale;
  final VoidCallback onTap;

  const _BoardCell({
    required this.index,
    required this.value,
    required this.notes,
    required this.isSelected,
    required this.sameValue,
    required this.incorrect,
    required this.fontScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final baseInner = colors.boardInner;
    final thinColor = Color.alphaBlend(
      theme.colorScheme.onSurface.withOpacity(0.08),
      baseInner,
    );
    final boldColor = Color.alphaBlend(
      theme.colorScheme.onSurface.withOpacity(0.18),
      baseInner,
    );
    final border = _cellBorder(index, thinColor, boldColor);
    final highlightSameValue = value != 0 && sameValue && !isSelected;
    final backgroundColor = isSelected
        ? colors.selectedCell
        : highlightSameValue
            ? colors.sameNumberCell
            : colors.boardInner;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
        ),
        child: _CellContent(
          value: value,
          notes: notes,
          incorrect: incorrect,
          fontScale: fontScale,
        ),
      ),
    );
  }
}

class _CellContent extends StatelessWidget {
  final int value;
  final Set<int> notes;
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
    final colors = theme.extension<SudokuColors>()!;
    final onSurface = theme.colorScheme.onSurface;
    if (value != 0) {
      return Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          style: TextStyle(
            fontSize: 20 * fontScale,
            fontWeight: FontWeight.w600,
            color: incorrect ? theme.colorScheme.error : onSurface,
          ),
          child: Text(value.toString()),
        ),
      );
    }

    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = notes.toList()..sort();
    return _NotesGrid(
      notes: notes,
      fontScale: fontScale,
      key: ValueKey('notes-${sorted.join('-')}'),
    );
  }
}

class _NotesGrid extends StatelessWidget {
  final Set<int> notes;
  final double fontScale;

  const _NotesGrid({super.key, required this.notes, required this.fontScale});

  @override
  Widget build(BuildContext context) {
    final sorted = notes.toList()..sort();
    final colors = Theme.of(context).extension<SudokuColors>()!;
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Wrap(
          spacing: 4,
          runSpacing: 2,
          children: [
            for (final note in sorted)
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
