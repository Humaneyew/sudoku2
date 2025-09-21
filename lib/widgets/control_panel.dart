import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import '../models.dart';
import '../theme.dart';
import '../undo_ad_controller.dart';

const double _actionButtonRadiusValue = 20;
const double _actionBadgeRadiusValue = 12;
const double kControlPanelVerticalSpacing = 16.0;

class ControlPanel extends StatelessWidget {
  final double scale;

  const ControlPanel({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: const ValueKey('control-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ActionRow(scale: scale),
          SizedBox(height: kControlPanelVerticalSpacing * scale),
          _NumberPad(scale: scale),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final double scale;

  const _ActionRow({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _UndoButton(scale: scale)),
        SizedBox(width: 12 * scale),
        Expanded(child: _EraseButton(scale: scale)),
        SizedBox(width: 12 * scale),
        Expanded(child: _NotesButton(scale: scale)),
        SizedBox(width: 12 * scale),
        Expanded(child: _HintButton(scale: scale)),
      ],
    );
  }
}

class _UndoButton extends StatelessWidget {
  final double scale;

  const _UndoButton({required this.scale});

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
              scale: scale,
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
  final double scale;

  const _EraseButton({required this.scale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Selector<AppState, bool>(
      selector: (_, app) => app.canErase,
      builder: (context, canErase, __) => _ActionButton(
        key: const ValueKey('action-erase'),
        scale: scale,
        icon: Icons.backspace_outlined,
        label: l10n.erase,
        onPressed: canErase ? context.read<AppState>().eraseCell : null,
      ),
    );
  }
}

class _NotesButton extends StatelessWidget {
  final double scale;

  const _NotesButton({required this.scale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Selector<AppState, bool>(
      selector: (_, app) => app.isNotesMode,
      builder: (context, notesMode, __) => _ActionButton(
        key: const ValueKey('action-notes'),
        scale: scale,
        icon: Icons.edit_note,
        label: l10n.notes,
        onPressed: context.read<AppState>().toggleNotesMode,
        active: notesMode,
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  final double scale;

  const _HintButton({required this.scale});

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
          scale: scale,
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
  final double scale;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.badge,
    this.badgeColor,
    this.active = false,
    required this.scale,
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
    final height = 84 * scale;
    final borderRadius = BorderRadius.circular(_actionButtonRadiusValue * scale);
    final badgeRadius = BorderRadius.circular(_actionBadgeRadiusValue * scale);
    final blurRadius = 12 * scale;
    final offsetY = 6 * scale;
    final verticalPadding = 12 * scale;
    final horizontalPadding = 8 * scale;
    final badgeHorizontalPadding = 6 * scale;
    final badgeVerticalPadding = 2 * scale;
    final iconSize = 26 * scale;
    final spacing = 8 * scale;

    return MediaQuery(
      data: mediaQuery.copyWith(textScaleFactor: clampedTextScale),
      child: SizedBox(
        height: height,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: background,
            borderRadius: borderRadius,
            border: Border.all(color: effectiveBorder),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colors.shadowColor,
                      blurRadius: blurRadius,
                      offset: Offset(0, offsetY),
                    ),
                  ]
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: enabled ? onPressed : null,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: horizontalPadding,
                ),
                child: Stack(
                  children: [
                    if (showBadge)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: badgeHorizontalPadding,
                            vertical: badgeVerticalPadding,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBackground,
                            borderRadius: badgeRadius,
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
                          Icon(icon, size: iconSize, color: iconColor),
                          SizedBox(height: spacing),
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
  final double scale;

  const _NumberPad({required this.scale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final media = MediaQuery.of(context);
    final reduceMotion = media.disableAnimations;
    final bool isTablet = media.size.shortestSide >= 600;

    final baseHorizontalPadding = isTablet ? 20.0 : 8.0;
    final horizontalPadding = baseHorizontalPadding / scale;
    final verticalPadding = (isTablet ? 20.0 : 16.0) * scale;
    final borderRadius = BorderRadius.circular(28 * scale);
    final blurRadius = 20 * scale;
    final offsetY = 12 * scale;

    return Container(
      decoration: BoxDecoration(
        color: colors.numberPadBackground,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: blurRadius,
            offset: Offset(0, offsetY),
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

          const double minGap = 2.0;
          const double maxGap = 4.0;

          double gap = maxGap;
          double availableWidth = maxWidth - gap * 8;

          if (availableWidth < 0) {
            gap = minGap;
            availableWidth = maxWidth - gap * 8;
            if (availableWidth < 0) {
              gap = 0.0;
              availableWidth = maxWidth;
            }
          }

          availableWidth = math.max(0.0, availableWidth);
          final double buttonWidth = availableWidth / 9;
          final double baseMinWidth = isTablet ? 56.0 : 48.0;

          final double widthScale =
              (buttonWidth / baseMinWidth).clamp(0.9, isTablet ? 1.6 : 1.3).toDouble();
          final double minHeight = isTablet ? 80.0 : 68.0;
          final double heightMultiplier = isTablet ? 1.18 : 1.12;
          final double buttonHeight =
              math.max(minHeight, buttonWidth * heightMultiplier);
          final double scaledButtonHeight = buttonHeight * scale;
          final double labelSpacing =
              (scaledButtonHeight * 0.1).clamp(4.0 * scale, 12.0 * scale).toDouble();

          final children = <Widget>[];
          for (var i = 0; i < 9; i++) {
            children.add(
              Expanded(
                child: _DigitButton(
                  number: i + 1,
                  theme: theme,
                  colors: colors,
                  reduceMotion: reduceMotion,
                  buttonHeight: scaledButtonHeight,
                  widthScale: widthScale,
                  labelSpacing: labelSpacing,
                  scale: scale,
                ),
              ),
            );
            if (i < 8) {
              children.add(SizedBox(width: gap));
            }
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
  final double scale;

  const _DigitButton({
    required this.number,
    required this.theme,
    required this.colors,
    required this.reduceMotion,
    required this.buttonHeight,
    required this.widthScale,
    required this.labelSpacing,
    required this.scale,
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
          scale: scale,
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
  final double scale;

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
    required this.scale,
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
              blurRadius: 12 * scale,
              offset: Offset(0, 6 * scale),
            ),
          ]
        : null;
    final borderRadius = BorderRadius.circular(
      math.max(18.0 * scale, math.min(24.0 * scale, height / 2.2)),
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
          padding: EdgeInsets.symmetric(horizontal: 4 * scale),
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

double estimateControlPanelHeight({
  required double maxWidth,
  required double scale,
  required bool isTablet,
}) {
  if (maxWidth <= 0 || scale <= 0) {
    return 0;
  }

  const double minGap = 2.0;
  const double maxGap = 4.0;
  final double actionRowHeight = 84 * scale;
  final double spacing = kControlPanelVerticalSpacing * scale;
  final double horizontalPadding = (isTablet ? 20.0 : 8.0) / scale;
  final double verticalPadding = (isTablet ? 20.0 : 16.0) * scale;

  final double innerWidth = math.max(0.0, maxWidth - horizontalPadding * 2);

  double gap = maxGap;
  double availableWidth = innerWidth - gap * 8;
  if (availableWidth < 0) {
    gap = minGap;
    availableWidth = innerWidth - gap * 8;
    if (availableWidth < 0) {
      gap = 0.0;
      availableWidth = innerWidth;
    }
  }

  availableWidth = math.max(0.0, availableWidth);
  final double buttonWidth = availableWidth / 9;
  final double minHeight = isTablet ? 80.0 : 68.0;
  final double heightMultiplier = isTablet ? 1.18 : 1.12;
  final double buttonHeight = math.max(minHeight, buttonWidth * heightMultiplier);
  final double scaledButtonHeight = buttonHeight * scale;
  final double numberPadHeight = verticalPadding * 2 + scaledButtonHeight;

  return actionRowHeight + spacing + numberPadHeight;
}

