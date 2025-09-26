import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'combo_theme.dart';

class ComboToast extends StatelessWidget {
  final String message;
  final String iconAsset;
  final double fontScale;
  final double maxWidth;

  const ComboToast({
    super.key,
    required this.message,
    required this.iconAsset,
    required this.fontScale,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comboTheme = theme.extension<ComboTheme>() ??
        const ComboTheme(
          tintStrength: 0.1,
          maxQueue: 5,
          throttleMs: 800,
          inMs: 200,
          outMs: 200,
          offsetY: 10,
          baseHeight: 56,
          displayMs: 1000,
          elevation: 2,
          containerOpacity: 0.85,
          outlineOpacity: 0.24,
        );
    final scheme = theme.colorScheme;
    final background = Color.alphaBlend(
      scheme.primary.withOpacity(comboTheme.tintStrength),
      scheme.surface,
    ).withOpacity(comboTheme.containerOpacity);
    final borderColor = scheme.onSurface.withOpacity(comboTheme.outlineOpacity);
    final onSurface = scheme.onSurface.withOpacity(0.8);
    final baseStyle = theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    final resolvedFontSize = (baseStyle.fontSize ?? 16) * fontScale;
    final textStyle = baseStyle.copyWith(
      fontSize: resolvedFontSize,
      fontWeight: FontWeight.w600,
      color: onSurface,
    );
    final shape = theme.cardTheme.shape;
    BorderRadius borderRadius;
    if (shape is RoundedRectangleBorder) {
      borderRadius = shape.borderRadius.resolve(Directionality.of(context));
    } else {
      borderRadius = BorderRadius.circular(14);
    }

    final constrainedWidth = math.min(360.0, maxWidth);
    final resolvedHeight = math.max(comboTheme.baseHeight, resolvedFontSize * 2.8);

    return RepaintBoundary(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constrainedWidth),
        child: Material(
          elevation: comboTheme.elevation,
          color: background,
          shadowColor: scheme.shadow.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(color: borderColor, width: 2),
          ),
          child: Container(
            height: resolvedHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(onSurface, BlendMode.srcIn),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: textStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
