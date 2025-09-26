import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Theme settings for combo toasts.
class ComboTheme extends ThemeExtension<ComboTheme> {
  final double tintStrength;
  final int maxQueue;
  final int throttleMs;
  final int inMs;
  final int outMs;
  final double offsetY;
  final double baseHeight;
  final int displayMs;
  final double elevation;
  final double containerOpacity;
  final double outlineOpacity;

  const ComboTheme({
    required this.tintStrength,
    required this.maxQueue,
    required this.throttleMs,
    required this.inMs,
    required this.outMs,
    required this.offsetY,
    required this.baseHeight,
    required this.displayMs,
    required this.elevation,
    required this.containerOpacity,
    required this.outlineOpacity,
  });

  @override
  ComboTheme copyWith({
    double? tintStrength,
    int? maxQueue,
    int? throttleMs,
    int? inMs,
    int? outMs,
    double? offsetY,
    double? baseHeight,
    int? displayMs,
    double? elevation,
    double? containerOpacity,
    double? outlineOpacity,
  }) {
    return ComboTheme(
      tintStrength: tintStrength ?? this.tintStrength,
      maxQueue: maxQueue ?? this.maxQueue,
      throttleMs: throttleMs ?? this.throttleMs,
      inMs: inMs ?? this.inMs,
      outMs: outMs ?? this.outMs,
      offsetY: offsetY ?? this.offsetY,
      baseHeight: baseHeight ?? this.baseHeight,
      displayMs: displayMs ?? this.displayMs,
      elevation: elevation ?? this.elevation,
      containerOpacity: containerOpacity ?? this.containerOpacity,
      outlineOpacity: outlineOpacity ?? this.outlineOpacity,
    );
  }

  @override
  ComboTheme lerp(ThemeExtension<ComboTheme>? other, double t) {
    if (other is! ComboTheme) {
      return this;
    }
    return ComboTheme(
      tintStrength:
          ui.lerpDouble(tintStrength, other.tintStrength, t) ?? tintStrength,
      maxQueue: ui
              .lerpDouble(maxQueue.toDouble(), other.maxQueue.toDouble(), t)
              ?.round() ??
          maxQueue,
      throttleMs: ui
              .lerpDouble(throttleMs.toDouble(), other.throttleMs.toDouble(), t)
              ?.round() ??
          throttleMs,
      inMs: ui.lerpDouble(inMs.toDouble(), other.inMs.toDouble(), t)?.round() ?? inMs,
      outMs: ui
              .lerpDouble(outMs.toDouble(), other.outMs.toDouble(), t)
              ?.round() ??
          outMs,
      offsetY: ui.lerpDouble(offsetY, other.offsetY, t) ?? offsetY,
      baseHeight: ui.lerpDouble(baseHeight, other.baseHeight, t) ?? baseHeight,
      displayMs: ui
              .lerpDouble(displayMs.toDouble(), other.displayMs.toDouble(), t)
              ?.round() ??
          displayMs,
      elevation: ui.lerpDouble(elevation, other.elevation, t) ?? elevation,
      containerOpacity: ui
              .lerpDouble(containerOpacity, other.containerOpacity, t) ??
          containerOpacity,
      outlineOpacity: ui
              .lerpDouble(outlineOpacity, other.outlineOpacity, t) ?? outlineOpacity,
    );
  }
}
