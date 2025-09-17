import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';

class Board extends StatelessWidget {
  const Board({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;

    return Consumer<AppState>(
      builder: (context, app, _) {
        final game = app.current;
        if (game == null) {
          return const SizedBox.shrink();
        }

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
                  final incorrect = !given &&
                      value != 0 &&
                      !app.isMoveValid(index, value);

                  return _BoardCell(
                    index: index,
                    value: value,
                    notes: notes,
                    given: given,
                    isSelected: isSelected,
                    sameValue: sameValue,
                    incorrect: incorrect,
                    onTap: () => app.selectCell(index),
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
  final bool sameValue;
  final bool incorrect;
  final VoidCallback onTap;

  const _BoardCell({
    required this.index,
    required this.value,
    required this.notes,
    required this.given,
    required this.isSelected,
    required this.sameValue,
    required this.incorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = _cellBorder(index);
    final highlightSameValue = value != 0 && sameValue;
    final backgroundColor = (isSelected || highlightSameValue)
        ? const Color(0xFFB0C4DE)
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
        ),
        child: Center(
          child: _CellContent(
            value: value,
            notes: notes,
            given: given,
            incorrect: incorrect,
          ),
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
          color: incorrect ? const Color(0xFFFF0000) : Colors.black,
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
  const thinLineColor = Color(0xFFD3D3D3);
  const boldLineColor = Color(0xFF555555);
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
