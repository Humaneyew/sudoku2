import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import '../models.dart';
import '../theme.dart';
import '../undo_ad_controller.dart';

const BorderRadius _actionButtonRadius = BorderRadius.all(Radius.circular(20));
const BorderRadius _actionBadgeRadius = BorderRadius.all(Radius.circular(12));

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: const ValueKey('control-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _ActionRow(),
          SizedBox(height: 20),
          _NumberPad(),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _UndoButton()),
        SizedBox(width: 12),
        Expanded(child: _EraseButton()),
        SizedBox(width: 12),
        Expanded(child: _NotesButton()),
        SizedBox(width: 12),
        Expanded(child: _HintButton()),
      ],
    );
  }
}

class _UndoButton extends StatelessWidget {
  const _UndoButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<UndoAdController>(
      builder: (context, undoAds, _) {
        final useUndoAd = undoAds.useAdFlow;
        return Selector<AppState, bool>(
          selector: (_, app) => app.canUndoMove,
          builder: (context, canUndo, __) {
            final undoEnabled =
                canUndo && (!useUndoAd || undoAds.isAdAvailable);
            return _ActionButton(
              key: const ValueKey('action-undo'),
              icon: Icons.undo_rounded,
              label: l10n.undo,
              onPressed: undoEnabled
                  ? () async {
                      final app = context.read<AppState>();
                      if (useUndoAd) {
                        final shown = await undoAds.showAd(context);
                        if (!context.mounted) {
                          return;
                        }
                        if (!shown || !app.canUndoMove) {
                          return;
                        }
                      }
                      app.undoMove();
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}

class _EraseButton extends StatelessWidget {
  const _EraseButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Selector<AppState, bool>(
      selector: (_, app) => app.canErase,
      builder: (context, canErase, __) => _ActionButton(
        key: const ValueKey('action-erase'),
        icon: Icons.backspace_outlined,
        label: l10n.erase,
        onPressed: canErase ? context.read<AppState>().eraseCell : null,
      ),
    );
  }
}

class _NotesButton extends StatelessWidget {
  const _NotesButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Selector<AppState, bool>(
      selector: (_, app) => app.isNotesMode,
      builder: (context, notesMode, __) => _ActionButton(
        key: const ValueKey('action-notes'),
        icon: Icons.edit_note,
        label: l10n.notes,
        onPressed: context.read<AppState>().toggleNotesMode,
        active: notesMode,
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  const _HintButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Selector<AppState, int>(
      selector: (_, app) => app.hintsLeft,
      builder: (context, hintsLeft, __) {
        final enabled = hintsLeft > 0;
        final badgeColor = enabled ? cs.secondary : theme.disabledColor;
        return _ActionButton(
          key: const ValueKey('action-hint'),
          icon: Icons.lightbulb_outline,
          label: l10n.hint,
          onPressed: enabled ? context.read<AppState>().useHint : null,
          badge: hintsLeft.toString(),
          badgeColor: badgeColor,
        );
      },
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
    super.key,
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
    final cs = theme.colorScheme;
    final colors = theme.extension<SudokuColors>()!;
    final enabled = onPressed != null;
    final isActive = enabled && active;
    final background = isActive
        ? colors.actionButtonActiveBackground
        : cs.surface;
    final borderColor = isActive
        ? colors.actionButtonActiveBorder
        : cs.outlineVariant;
    final disabledBorder = Color.alphaBlend(
      cs.onSurface.withOpacity(0.05),
      cs.surface,
    );
    final effectiveBorder = enabled ? borderColor : disabledBorder;
    final disabledColor = cs.onSurface.withOpacity(0.35);
    final textColor = isActive
        ? cs.primary
        : enabled
            ? cs.onSurface
            : disabledColor;
    final iconColor = isActive
        ? cs.primary
        : enabled
            ? cs.onSurface
            : disabledColor;
    final baseBadge = badgeColor ?? colors.actionButtonBadgeColor;
    final badgeForeground = enabled ? baseBadge : baseBadge.withOpacity(0.4);
    final badgeBackground = enabled
        ? baseBadge.withOpacity(0.18)
        : baseBadge.withOpacity(0.12);
    final showBadge = badge != null && badge!.isNotEmpty;

    final mediaQuery = MediaQuery.of(context);
    final clampedTextScale = mediaQuery.textScaleFactor.clamp(0.0, 1.2);

    return MediaQuery(
      data: mediaQuery.copyWith(textScaleFactor: clampedTextScale),
      child: SizedBox(
        height: 84,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: background,
            borderRadius: _actionButtonRadius,
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
              borderRadius: _actionButtonRadius,
              onTap: enabled ? onPressed : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
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
                            borderRadius: _actionBadgeRadius,
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
                          SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
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
      ),
    );
  }
}

class _DigitVM {
  final int remaining;
  final bool selected;
  final bool highlighted;
  final bool enabled;
  final bool notesMode;
  final double fontScale;

  const _DigitVM({
    required this.remaining,
    required this.selected,
    required this.highlighted,
    required this.enabled,
    required this.notesMode,
    required this.fontScale,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _DigitVM &&
            other.remaining == remaining &&
            other.selected == selected &&
            other.highlighted == highlighted &&
            other.enabled == enabled &&
            other.notesMode == notesMode &&
            other.fontScale == fontScale;
  }

  @override
  int get hashCode => Object.hash(
        remaining,
        selected,
        highlighted,
        enabled,
        notesMode,
        fontScale,
      );
}

class _NumberPad extends StatelessWidget {
  const _NumberPad();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final media = MediaQuery.of(context);
    final reduceMotion = media.disableAnimations;
    final bool isTablet = media.size.shortestSide >= 600;

    final horizontalPadding = isTablet ? 20.0 : 8.0;
    final verticalPadding = isTablet ? 20.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.numberPadBackground,
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          if (maxWidth <= 0) {
            return const SizedBox.shrink();
          }

          final double baseMinWidth = isTablet ? 56.0 : 48.0;
          final double desiredWidth = isTablet ? 72.0 : 56.0;
          const double minGap = 2.0;
          const double maxGap = 12.0;

          double gap = minGap;
          double availableWidth = math.max(0.0, maxWidth - gap * 8);
          double buttonWidth = availableWidth / 9;

          if (buttonWidth >= desiredWidth) {
            final double expandedGap =
                ((maxWidth - desiredWidth * 9) / 8).clamp(minGap, maxGap).toDouble();
            gap = expandedGap;
            availableWidth = math.max(0.0, maxWidth - gap * 8);
            buttonWidth = availableWidth / 9;
          } else if (buttonWidth < baseMinWidth) {
            final double tightenedGap =
                ((maxWidth - baseMinWidth * 9) / 8).clamp(0.0, minGap).toDouble();
            gap = math.max(0.0, tightenedGap);
            availableWidth = math.max(0.0, maxWidth - gap * 8);
            buttonWidth = availableWidth / 9;
          }

          final double widthScale =
              (buttonWidth / baseMinWidth).clamp(0.9, isTablet ? 1.6 : 1.3).toDouble();
          final double minHeight = isTablet ? 80.0 : 68.0;
          final double heightMultiplier = isTablet ? 1.18 : 1.12;
          final double buttonHeight =
              math.max(minHeight, buttonWidth * heightMultiplier);
          final double labelSpacing =
              (buttonHeight * 0.1).clamp(4.0, 12.0).toDouble();

          final children = <Widget>[];
          for (var i = 0; i < 9; i++) {
            children.add(SizedBox(
              width: buttonWidth,
              child: _DigitButton(
                number: i + 1,
                theme: theme,
                colors: colors,
                reduceMotion: reduceMotion,
                buttonHeight: buttonHeight,
                widthScale: widthScale,
                labelSpacing: labelSpacing,
              ),
            ));
            if (i < 8) {
              children.add(SizedBox(width: gap));
            }
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          );
        },
      ),
    );
  }
}

class _DigitButton extends StatelessWidget {
  final int number;
  final ThemeData theme;
  final SudokuColors colors;
  final bool reduceMotion;
  final double buttonHeight;
  final double widthScale;
  final double labelSpacing;

  const _DigitButton({
    required this.number,
    required this.theme,
    required this.colors,
    required this.reduceMotion,
    required this.buttonHeight,
    required this.widthScale,
    required this.labelSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, _DigitVM>(
      selector: (_, app) => _DigitVM(
        remaining: app.countRemaining(number),
        selected: app.selectedValue == number,
        highlighted: app.highlightedNumber == number,
        enabled: !app.isNumberCompleted(number),
        notesMode: app.isNotesMode,
        fontScale: app.fontScale,
      ),
      builder: (context, vm, __) {
        final app = context.read<AppState>();
        return _NumberButton(
          key: ValueKey('digit-$number'),
          number: number,
          remaining: vm.remaining,
          selected: vm.selected,
          highlighted: vm.highlighted,
          enabled: vm.enabled,
          onTap: () => app.handleNumberInput(number),
          onHighlightStart: () => app.setHighlightedNumber(number),
          onHighlightEnd: () => app.setHighlightedNumber(null),
          theme: theme,
          reduceMotion: reduceMotion,
          notesMode: vm.notesMode,
          colors: colors,
          fontScale: vm.fontScale,
          height: buttonHeight,
          widthScale: widthScale,
          labelSpacing: labelSpacing,
        );
      },
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
  final double fontScale;
  final double height;
  final double widthScale;
  final double labelSpacing;

  const _NumberButton({
    super.key,
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
    required this.fontScale,
    required this.height,
    required this.widthScale,
    required this.labelSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = enabled && selected;
    final isHighlighted = enabled && highlighted;
    final cs = theme.colorScheme;
    final background = !enabled
        ? colors.numberPadDisabledBackground
        : isSelected
            ? colors.numberPadSelectedBackground
            : isHighlighted
                ? colors.numberPadHighlightBackground
                : colors.numberPadBackground;
    final borderColor = !enabled
        ? Color.alphaBlend(
            cs.onSurface.withOpacity(0.05),
            colors.numberPadBackground,
          )
        : isSelected
            ? colors.numberPadSelectedBorder
            : isHighlighted
                ? colors.numberPadHighlightBorder
                : colors.numberPadBorder;
    final textColor = !enabled
        ? colors.numberPadDisabledText
        : notesMode && !isSelected && !isHighlighted
            ? cs.onSurface.withOpacity(0.7)
            : cs.onSurface;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 160);
    final baseNumberSize = (notesMode ? 18.0 : 20.0) * fontScale;
    final numberFontSize =
        (baseNumberSize * widthScale).clamp(18.0, isSelected ? 34.0 : 32.0).toDouble();
    final remainingColor = !enabled
        ? colors.numberPadDisabledText
        : isHighlighted
            ? colors.numberPadRemainingHighlight
            : colors.numberPadRemaining;
    final baseRemainingSize = 12.0 * fontScale;
    final remainingFontSize =
        (baseRemainingSize * math.max(1.0, widthScale * 0.9)).clamp(10.0, 18.0).toDouble();
    final shadow = isSelected
        ? [
            BoxShadow(
              color: colors.shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ]
        : null;
    final borderRadius = BorderRadius.circular(
      math.max(18.0, math.min(24.0, height / 2.2)),
    );

    return AnimatedOpacity(
      duration: duration,
      opacity: enabled ? 1.0 : 0.0,
      child: InkWell(
        borderRadius: borderRadius,
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
          height: height,
          decoration: BoxDecoration(
            color: background,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
            boxShadow: shadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: numberFontSize,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                child: Text(number.toString()),
              ),
              SizedBox(height: labelSpacing),
              AnimatedDefaultTextStyle(
                duration: duration,
                style: TextStyle(
                  fontSize: remainingFontSize,
                  color: remainingColor,
                ),
                child: Text(remaining.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

