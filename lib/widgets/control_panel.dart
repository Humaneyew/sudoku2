import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActionRow(app: app),
        const SizedBox(height: 20),
        _NumberPad(app: app),
        const SizedBox(height: 16),
        const _AdBanner(),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final AppState app;

  const _ActionRow({required this.app});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x121B1D3A),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.undo_rounded,
            label: 'Скасувати',
            onTap: app.undoMove,
          ),
          _ActionButton(
            icon: Icons.backspace_outlined,
            label: 'Стерти',
            onTap: app.eraseCell,
          ),
          _ActionButton(
            icon: Icons.auto_awesome,
            label: 'Автоматичні нотатки',
            onTap: app.toggleAutoNotes,
            chipLabel: app.autoNotes ? 'УВІМК' : 'ВИМК',
            chipColor:
                app.autoNotes ? const Color(0xFF3B82F6) : theme.disabledColor,
          ),
          _ActionButton(
            icon: Icons.edit_note,
            label: 'Нотатки',
            onTap: app.toggleNotesMode,
            chipLabel: app.notesMode ? 'УВІМК' : 'ВИМК',
            chipColor:
                app.notesMode ? const Color(0xFF3B82F6) : theme.disabledColor,
          ),
          _ActionButton(
            icon: Icons.lightbulb_outline,
            label: 'Підказка',
            onTap: app.hintsLeft > 0 ? app.useHint : null,
            chipLabel: app.hintsLeft.toString(),
            chipColor: app.hintsLeft > 0
                ? const Color(0xFFFFB347)
                : theme.disabledColor,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? chipLabel;
  final Color? chipColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.chipLabel,
    this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = onTap == null
        ? theme.disabledColor
        : const Color(0xFF3B82F6);

    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFD8E6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF48506C),
              ),
            ),
            if (chipLabel != null) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (chipColor ?? theme.disabledColor).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chipLabel!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: chipColor ?? theme.disabledColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final AppState app;

  const _NumberPad({required this.app});

  @override
  Widget build(BuildContext context) {
    final selected = app.selectedValue;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141B1D3A),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          for (var i = 0; i < 9; i++)
            Expanded(
              child: _NumberButton(
                number: i + 1,
                remaining: app.countRemaining(i + 1),
                selected: selected == i + 1,
                onTap: () => app.handleNumberInput(i + 1),
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final int remaining;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _NumberButton({
    required this.number,
    required this.remaining,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected ? const Color(0xFFC7DBFF) : Colors.white;
    final borderColor = selected ? const Color(0xFF3B82F6) : const Color(0xFFE2E5F3);
    final textColor = selected ? const Color(0xFF1F2437) : const Color(0xFF1F2437);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                remaining.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.disabledColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdBanner extends StatelessWidget {
  const _AdBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.play_circle_fill, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Реклама: Знайди приховані об’єкти! Грай зараз.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'Play',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
