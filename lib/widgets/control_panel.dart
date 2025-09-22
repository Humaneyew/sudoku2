import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import '../models.dart';
import '../theme.dart';
import '../undo_ad_controller.dart';

const double _actionButtonRadiusValue = 20;
const double _actionBadgeRadiusValue = 12;
const double _kControlPanelScaleIncrease = 1.05;
const double kControlPanelVerticalSpacing =
    10.0 / _kControlPanelScaleIncrease;
// Targets roughly a 7% reduction in the keypad banner height while
// preserving the digit sizing.
const double _kNumberPadVerticalPaddingScale = 0.7125;
// Keep the surrounding banner spacing aligned with the historical layout.
const double _kNumberPadSpacingCompensationScale =
    0.05 / _kControlPanelScaleIncrease;
const double _kCompactHeightBreakpoint = 720.0;

double _numberPadBasePadding({required bool isTablet}) => isTablet ? 18.0 : 14.0;

double _resolveHeightFactor({
  required bool isTablet,
  required bool compactLayout,
  required double screenHeight,
}) {
  if (compactLayout) {
    return 0.9;
  }
  if (!isTablet && screenHeight < _kCompactHeightBreakpoint) {
    return 0.9;
  }
  return 1.0;
}

double _resolveEffectiveHeightFactor({
  required bool isTablet,
  required double heightFactor,
  required double screenHeight,
}) {
  if (heightFactor < 1.0) {
    return heightFactor;
  }
  if (!isTablet && screenHeight < _kCompactHeightBreakpoint) {
    return 0.9;
  }
  return 1.0;
}

class ControlPanelLayoutConfig {
  final double heightFactor;
  final double effectiveHeightFactor;
  final double numberPadVerticalPadding;
  final double spacingCompensation;

  const ControlPanelLayoutConfig({
    required this.heightFactor,
    required this.effectiveHeightFactor,
    required this.numberPadVerticalPadding,
    required this.spacingCompensation,
  });
}

ControlPanelLayoutConfig resolveControlPanelLayoutConfig({
  required double scale,
  required bool isTablet,
  required bool compactLayout,
  required double screenHeight,
}) {
  final heightFactor =
      _resolveHeightFactor(isTablet: isTablet, compactLayout: compactLayout, screenHeight: screenHeight);
  final effectiveHeightFactor = _resolveEffectiveHeightFactor(
    isTablet: isTablet,
    heightFactor: heightFactor,
    screenHeight: screenHeight,
  );
  final basePadding = _numberPadBasePadding(isTablet: isTablet) * scale * effectiveHeightFactor;
  final verticalPadding = basePadding * _kNumberPadVerticalPaddingScale;
  final spacingCompensation = basePadding * _kNumberPadSpacingCompensationScale;

  return ControlPanelLayoutConfig(
    heightFactor: heightFactor,
    effectiveHeightFactor: effectiveHeightFactor,
    numberPadVerticalPadding: verticalPadding,
    spacingCompensation: spacingCompensation,
  );
}

class ControlPanel extends StatelessWidget {
  final double scale;
  final bool compactLayout;

  const ControlPanel({
    super.key,
    this.scale = 1.0,
    this.compactLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bool isTablet = media.size.shortestSide >= 600;
    final layout = resolveControlPanelLayoutConfig(
      scale: scale,
      isTablet: isTablet,
      compactLayout: compactLayout,
      screenHeight: media.size.height,
    );
    final double heightFactor = layout.heightFactor;
    final double effectiveHeightFactor = layout.effectiveHeightFactor;
    final double topInset = layout.spacingCompensation;
    final double spacingHeight =
        kControlPanelVerticalSpacing * scale * heightFactor + topInset;

    return RepaintBoundary(
      key: const ValueKey('control-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topInset),
          _ActionRow(scale: scale, heightFactor: heightFactor),
          SizedBox(height: spacingHeight),
          _NumberPad(
            scale: scale,
            heightFactor: heightFactor,
            isTablet: isTablet,
            effectiveHeightFactor: effectiveHeightFactor,
            verticalPadding: layout.numberPadVerticalPadding,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final double scale;
  final double heightFactor;

  const _ActionRow({required this.scale, required this.heightFactor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _UndoButton(scale: scale, heightFactor: heightFactor)),
        SizedBox(width: 10 * scale * heightFactor),
        Expanded(child: _EraseButton(scale: scale, heightFactor: heightFactor)),
        SizedBox(width: 10 * scale * heightFactor),
        Expanded(child: _NotesButton(scale: scale, heightFactor: heightFactor)),
        SizedBox(width: 10 * scale * heightFactor),
        Expanded(child: _HintButton(scale: scale, heightFactor: heightFactor)),
      ],
    );
  }
}

class _UndoButton extends StatelessWidget {
  final double scale;
  final double heightFactor;

  const _UndoButton({required this.scale, required this.heightFactor});

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
              heightFactor: heightFactor,
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
  final double heightFactor;

  const _EraseButton({required this.scale, required this.heightFactor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Selector<AppState, bool>(
      selector: (_, app) => app.canErase,
      builder: (context, canErase, __) => _ActionButton(
        key: const ValueKey('action-erase'),
        scale: scale,
        heightFactor: heightFactor,
        icon: Icons.backspace_outlined,
        label: l10n.erase,
        onPressed: canErase ? context.read<AppState>().eraseCell : null,
      ),
    );
  }
}

class _NotesButton extends StatelessWidget {
  final double scale;
  final double heightFactor;

  const _NotesButton({required this.scale, required this.heightFactor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Selector<AppState, bool>(
      selector: (_, app) => app.isNotesMode,
      builder: (context, notesMode, __) => _ActionButton(
        key: const ValueKey('action-notes'),
        scale: scale,
        heightFactor: heightFactor,
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
  final double heightFactor;

  const _HintButton({required this.scale, required this.heightFactor});

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
          heightFactor: heightFactor,
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
  final double heightFactor;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.badge,
    this.badgeColor,
    this.active = false,
    required this.scale,
    this.heightFactor = 1.0,
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
    final bool narrowWidth = mediaQuery.size.width < 360;
    final double widthFactor = narrowWidth ? 0.94 : 1.0;
    final double baseFactor = math.min(widthFactor, heightFactor);
    final double sizeFactor = baseFactor.clamp(0.85, 1.0).toDouble();
    final double minHeight = 56.0 * scale;
    final double height = math.max(minHeight, 72 * scale * sizeFactor);
    final double radiusValue =
        math.max(12.0, _actionButtonRadiusValue * scale * sizeFactor);
    final double badgeRadiusValue =
        math.max(8.0, _actionBadgeRadiusValue * scale * sizeFactor);
    final borderRadius = BorderRadius.circular(radiusValue);
    final badgeRadius = BorderRadius.circular(badgeRadiusValue);
    final double blurRadius = 10 * scale * sizeFactor;
    final double offsetY = 5 * scale * sizeFactor;
    final double verticalPadding =
        math.max(6.0, 10 * scale * sizeFactor);
    final double horizontalPadding =
        math.max(6.0, 8 * scale * sizeFactor);
    final double badgeHorizontalPadding =
        math.max(3.0, 6 * scale * sizeFactor);
    final double badgeVerticalPadding =
        math.max(1.0, 2 * scale * sizeFactor);
    final double iconSize = 24 * scale;
    final double spacing = math.max(4.0, 6 * scale * sizeFactor);

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
                              fontSize: 11 * _kControlPanelScaleIncrease,
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
                                  fontSize: 12 * _kControlPanelScaleIncrease,
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
  final double heightFactor;
  final bool isTablet;
  final double effectiveHeightFactor;
  final double verticalPadding;

  const _NumberPad({
    required this.scale,
    required this.heightFactor,
    required this.isTablet,
    required this.effectiveHeightFactor,
    required this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final media = MediaQuery.of(context);
    final reduceMotion = media.disableAnimations;
    final baseHorizontalPadding = isTablet ? 20.0 : 8.0;
    final horizontalPadding = baseHorizontalPadding / scale;
    final double radiusValue =
        math.max(18.0, 28 * scale * effectiveHeightFactor);
    final borderRadius = BorderRadius.circular(radiusValue);
    final double blurRadius = 20 * scale * effectiveHeightFactor;
    final double offsetY = 12 * scale * effectiveHeightFactor;

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
              (buttonWidth / baseMinWidth).clamp(0.95, isTablet ? 1.6 : 1.35).toDouble();
          final double minHeight = isTablet ? 80.0 : 68.0;
          final double heightMultiplier = isTablet ? 1.18 : 1.12;
          final double buttonHeight =
              math.max(minHeight, buttonWidth * heightMultiplier);
          final double scaledButtonHeight =
              buttonHeight * scale * effectiveHeightFactor;
          final double labelSpacing = (scaledButtonHeight * 0.09)
              .clamp(3.5 * scale, 10.0 * scale)
              .toDouble();

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
    final numberFontSize = (baseNumberSize * widthScale * 1.05)
        .clamp(18.0, isSelected ? 36.0 : 34.0)
        .toDouble();
    final remainingColor = !enabled
        ? colors.numberPadDisabledText
        : isHighlighted
            ? colors.numberPadRemainingHighlight
            : colors.numberPadRemaining;
    final baseRemainingSize = 12.0 * fontScale;
    final remainingFontSize = (baseRemainingSize * math.max(1.0, widthScale * 0.92) * 1.02)
        .clamp(10.0, 18.0)
        .toDouble();
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
  required double screenHeight,
  bool isCompact = false,
}) {
  if (maxWidth <= 0 || scale <= 0) {
    return 0;
  }

  const double minGap = 2.0;
  const double maxGap = 4.0;
  final layout = resolveControlPanelLayoutConfig(
    scale: scale,
    isTablet: isTablet,
    compactLayout: isCompact,
    screenHeight: screenHeight,
  );
  final double heightFactor = layout.heightFactor;
  final double effectiveHeightFactor = layout.effectiveHeightFactor;
  final double topInset = layout.spacingCompensation;
  final double actionRowHeight =
      math.max(56.0 * scale, 72 * scale * heightFactor);
  final double baseSpacing = kControlPanelVerticalSpacing * scale * heightFactor;
  final double horizontalPadding = (isTablet ? 20.0 : 8.0) / scale;
  final double verticalPadding = layout.numberPadVerticalPadding;

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
  final double scaledButtonHeight = buttonHeight * scale * effectiveHeightFactor;
  final double numberPadHeight = verticalPadding * 2 + scaledButtonHeight;

  return topInset + actionRowHeight + baseSpacing + topInset + numberPadHeight;
}

