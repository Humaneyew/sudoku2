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
      return const Center(child: Text("Нет активной игры"));
    }

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (context, i) {
          final value = game.board[i];
          final given = game.given[i];
          final isSelected = app.selectedCell == i;

          // Проверка на ошибку (если пользователь ввёл неверное значение)
          final isError = !given &&
              value != 0 &&
              !app.isMoveValid(i, value);

          return GestureDetector(
            onTap: () => app.selectCell(i),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: (i ~/ 9) % 3 == 0 ? 2 : 0.5,
                    color: Colors.black,
                  ),
                  left: BorderSide(
                    width: (i % 9) % 3 == 0 ? 2 : 0.5,
                    color: Colors.black,
                  ),
                  right: BorderSide(
                    width: (i % 9 == 8) ? 2 : 0.5,
                    color: Colors.black,
                  ),
                  bottom: BorderSide(
                    width: (i ~/ 9 == 8) ? 2 : 0.5,
                    color: Colors.black,
                  ),
                ),
                color: isSelected
                    ? Colors.lightBlueAccent.withOpacity(0.5)
                    : (isError ? Colors.redAccent.withOpacity(0.5) : Colors.white),
              ),
              child: Center(
                child: Text(
                  value == 0 ? "" : value.toString(),
                  style: TextStyle(
                    fontWeight: given ? FontWeight.bold : FontWeight.normal,
                    color: given ? Colors.black : Colors.blue[800],
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
