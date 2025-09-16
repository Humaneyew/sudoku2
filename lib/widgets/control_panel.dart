import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';

class ControlPanel extends StatelessWidget {
  final void Function(int number) onNumberSelected;

  const ControlPanel({super.key, required this.onNumberSelected});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Column(
      children: [
        // Кнопки 1–9
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: 9,
          itemBuilder: (context, i) {
            final number = i + 1;
            final left = app.countRemaining(number);

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                foregroundColor: Colors.white,
              ),
              onPressed: () => onNumberSelected(number),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    number.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    left.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        // Панель управления
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              icon: Icons.undo,
              label: "Отмена",
              onTap: () => app.undoMove(),
            ),
            _buildActionButton(
              context,
              icon: Icons.clear,
              label: "Стереть",
              onTap: () => app.eraseCell(),
            ),
            _buildActionButton(
              context,
              icon: Icons.edit,
              label: app.notesMode ? "Заметки" : "Нотатки",
              active: app.notesMode,
              onTap: () => app.toggleNotesMode(),
            ),
            _buildActionButton(
              context,
              icon: Icons.lightbulb,
              label: "Подсказка (${app.hintsLeft})",
              disabled: app.hintsLeft <= 0,
              onTap: () => app.useHint(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    bool disabled = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = disabled
        ? theme.disabledColor
        : (active ? colorScheme.primary : colorScheme.onSurface);

    return Column(
      children: [
        IconButton(
          onPressed: disabled ? null : onTap,
          icon: Icon(
            icon,
            color: iconColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: disabled
                ? theme.disabledColor
                : (active ? colorScheme.primary : colorScheme.onSurface),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
