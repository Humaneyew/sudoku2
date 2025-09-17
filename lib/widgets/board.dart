import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';

class Board extends StatelessWidget {
  const Board({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final game = app.current;

    if (game == null) {
      return const SizedBox.shrink();
    }

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
        child: GridView.builder(
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
            final isPeer = app.isPeerOfSelected(index);
            final sameValue = app.isSameAsSelectedValue(index);
            final conflict = app.hasConflict(index);
            final incorrect = !given && value != 0 && !app.isMoveValid(index, value);

            Color background = Colors.white;
            if (isPeer) {
              background = const Color(0xFFF3F6FF);
            }
            if (sameValue) {
              background = const Color(0xFFDAE8FF);
            }
            if (isSelected) {
              background = const Color(0xFFC7DBFF);
            }
            if (conflict) {
              background = const Color(0xFFFFE4E7);
            }

            final border = Border(
              top: BorderSide(
                color: const Color(0xFFB4C1E0),
                width: index ~/ 9 % 3 == 0 ? 1.6 : 0.5,
              ),
              left: BorderSide(
                color: const Color(0xFFB4C1E0),
                width: index % 9 % 3 == 0 ? 1.6 : 0.5,
              ),
              right: BorderSide(
                color: const Color(0xFFB4C1E0),
                width: index % 9 == 8 ? 1.6 : 0.5,
              ),
              bottom: BorderSide(
                color: const Color(0xFFB4C1E0),
                width: index ~/ 9 == 8 ? 1.6 : 0.5,
              ),
            );

            return GestureDetector(
              onTap: () => app.selectCell(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                decoration: BoxDecoration(
                  color: background,
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
          },
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
              : (given ? const Color(0xFF1F2437) : const Color(0xFF2563EB)),
        ),
      );
    }

    if (notes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 2,
        children: List.generate(9, (i) {
          final number = i + 1;
          final show = notes.contains(number);
          return SizedBox(
            width: 14,
            child: Text(
              show ? number.toString() : '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF96A0C4),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ),
    );
  }
}
