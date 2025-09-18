import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import '../models.dart';
import '../theme.dart';
import '../undo_ad_controller.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final undoAds = context.watch<UndoAdController>();
    final canUndoMove = app.canUndoMove;
    final useUndoAd = undoAds.useAdFlow;
    final undoEnabled = canUndoMove && (!useUndoAd || undoAds.isAdAvailable);

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.undo_rounded,
            label: l10n.undo,
            onPressed: undoEnabled
                ? () async {
                    if (useUndoAd) {
                      final shown = await undoAds.showAd(context);
                      if (!shown) {
                        return;
                      }
                      if (!app.canUndoMove) {
                        return;
                      }
                    }
                    app.undoMove();
                  }
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.backspace_outlined,
            label: l10n.erase,
            onPressed: app.eraseCell,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.edit_note,
            label: l10n.notes,
            onPressed: app.toggleNotesMode,
            active: app.notesMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.lightbulb_outline,
            label: l10n.hint,
            onPressed: app.hintsLeft > 0 ? app.useHint : null,
            badge: app.hintsLeft.toString(),
            badgeColor: app.hintsLeft > 0
                ? const Color(0xFFFFB347)
                : theme.disabledColor,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? badge;
  final Color? badgeColor;
  final bool active;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.badge,
    this.badgeColor,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final scheme = theme.colorScheme;
    final enabled = onPressed != null;
    final isActive = enabled && active;
    final background = isActive
        ? colors.actionButtonActiveBackground
        : scheme.surface;
    final borderColor = isActive
        ? colors.actionButtonActiveBorder
        : scheme.outlineVariant;
    final disabledBorder = Color.alphaBlend(
      scheme.onSurface.withOpacity(0.05),
      scheme.surface,
    );
    final effectiveBorder = enabled ? borderColor : disabledBorder;
    final disabledColor = scheme.onSurface.withOpacity(0.35);
    final textColor = isActive
        ? scheme.primary
        : enabled
            ? scheme.onSurface
            : disabledColor;
    final iconColor = isActive
        ? scheme.primary
        : enabled
            ? scheme.onSurface
            : disabledColor;
    final baseBadge = badgeColor ?? colors.actionButtonBadgeColor;
    final badgeForeground = enabled ? baseBadge : baseBadge.withOpacity(0.4);
    final badgeBackground = enabled
        ? baseBadge.withOpacity(0.18)
        : baseBadge.withOpacity(0.12);
    final showBadge = badge != null && badge!.isNotEmpty;

    return SizedBox(
      height: 84,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: effectiveBorder),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: colors.shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Stack(
                children: [
                  if (showBadge)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: badgeForeground,
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 26, color: iconColor),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    final colors = theme.extension<SudokuColors>()!;
    final highlighted = app.highlightedNumber;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final notesMode = app.notesMode;

    return Container(
      decoration: BoxDecoration(
        color: colors.numberPadBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
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
                highlighted: highlighted == i + 1,
                enabled: !app.isNumberCompleted(i + 1),
                onTap: () => app.handleNumberInput(i + 1),
                onHighlightStart: () => app.setHighlightedNumber(i + 1),
                onHighlightEnd: () => app.setHighlightedNumber(null),
                theme: theme,
                reduceMotion: reduceMotion,
                notesMode: notesMode,
                colors: colors,
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
  final bool highlighted;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onHighlightStart;
  final VoidCallback onHighlightEnd;
  final ThemeData theme;
  final bool reduceMotion;
  final bool notesMode;
  final SudokuColors colors;

  const _NumberButton({
    required this.number,
    required this.remaining,
    required this.selected,
    required this.highlighted,
    required this.enabled,
    required this.onTap,
    required this.onHighlightStart,
    required this.onHighlightEnd,
    required this.theme,
    required this.reduceMotion,
    required this.notesMode,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = enabled && selected;
    final isHighlighted = enabled && highlighted;
    final scheme = theme.colorScheme;
    final background = !enabled
        ? colors.numberPadDisabledBackground
        : isSelected
            ? colors.numberPadSelectedBackground
            : isHighlighted
                ? colors.numberPadHighlightBackground
                : colors.numberPadBackground;
    final borderColor = !enabled
        ? Color.alphaBlend(scheme.onSurface.withOpacity(0.05), colors.numberPadBackground)
        : isSelected
            ? colors.numberPadSelectedBorder
            : isHighlighted
                ? colors.numberPadHighlightBorder
                : colors.numberPadBorder;
    final textColor = !enabled
        ? colors.numberPadDisabledText
        : notesMode && !isSelected && !isHighlighted
            ? scheme.onSurface.withOpacity(0.7)
            : scheme.onSurface;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 160);
    final numberFontSize = notesMode ? 18.0 : 20.0;
    final remainingColor = !enabled
        ? colors.numberPadDisabledText
        : isHighlighted
            ? colors.numberPadRemainingHighlight
            : colors.numberPadRemaining;
    final shadow = isSelected
        ? [
            BoxShadow(
              color: colors.shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ]
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedOpacity(
        duration: duration,
        opacity: enabled ? 1.0 : 0.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTapDown: enabled ? (_) => onHighlightStart() : null,
          onTapCancel: enabled ? onHighlightEnd : null,
          onTap: enabled
              ? () {
                  onHighlightEnd();
                  onTap();
                }
              : null,
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              height: 64,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                boxShadow: shadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: numberFontSize,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  style: TextStyle(
                    fontSize: 12,
                    color: remainingColor,
                  ),
                  child: Text(remaining.toString()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

