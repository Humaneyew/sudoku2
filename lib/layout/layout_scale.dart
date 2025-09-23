import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Provides utilities for resolving a proportional scale factor based on
/// the available safe area size of the current device. The baseline layout
/// matches the design that targets a Pixel 7 screen size, ensuring that the
/// interface keeps its proportions on smaller phones as well as large
/// tablets.
class LayoutScale {
  const LayoutScale._();

  /// Logical width of the baseline design (Pixel 7 logical width).
  static const double _referenceWidth = 411;

  /// Logical height of the baseline design (Pixel 7 logical height).
  static const double _referenceHeight = 915;

  /// Minimum scale that keeps the layout legible on very small devices.
  static const double _minScale = 0.85;

  /// Maximum scale applied on large form factors to avoid overly large UI.
  static const double _maxScale = 1.35;

  /// Resolves a proportional scale value for the provided [media] query
  /// configuration. The calculation only uses the safe area dimensions to
  /// make sure that system insets such as display cutouts or gesture areas do
  /// not skew the result.
  static double resolve(MediaQueryData media) {
    final padding = media.viewPadding;
    final safeWidth = media.size.width - padding.left - padding.right;
    final safeHeight = media.size.height - padding.top - padding.bottom;

    if (safeWidth <= 0 || safeHeight <= 0) {
      return 1.0;
    }

    final widthScale = safeWidth / _referenceWidth;
    final heightScale = safeHeight / _referenceHeight;
    final scale = math.min(widthScale, heightScale);

    if (scale.isNaN || !scale.isFinite) {
      return 1.0;
    }

    return scale.clamp(_minScale, _maxScale);
  }
}

extension LayoutScaleExtension on BuildContext {
  /// Returns the proportional layout scale for the current [MediaQuery].
  double get layoutScale => LayoutScale.resolve(MediaQuery.of(this));

  /// Scales the provided [value] using [layoutScale].
  double scaled(double value) => value * layoutScale;

  /// Convenience for scaling font sizes together with the layout scale.
  double scaledFont(double size) => scaled(size);

  /// Returns symmetric padding scaled with the layout scale.
  EdgeInsets scaledSymmetricPadding({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal * layoutScale,
      vertical: vertical * layoutScale,
    );
  }
}
