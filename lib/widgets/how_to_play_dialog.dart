import 'package:flutter/material.dart';

import '../flutter_gen/gen_l10n/app_localizations.dart';
import '../layout/layout_scale.dart';

enum _TutorialHighlight { row, column, box }

Future<bool> showHowToPlayDialog(
  BuildContext context, {
  bool barrierDismissible = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return _HowToPlayDialog(barrierDismissible: barrierDismissible);
    },
  );
  return result ?? false;
}

class _HowToPlayDialog extends StatelessWidget {
  final bool barrierDismissible;

  const _HowToPlayDialog({required this.barrierDismissible});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scale = context.layoutScale;
    final colors = theme.colorScheme;
    final frameColor = colors.surfaceVariant.withOpacity(
      theme.brightness == Brightness.dark ? 0.35 : 0.65,
    );

    return WillPopScope(
      onWillPop: () async => barrierDismissible,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: 24 * scale,
          vertical: 24 * scale,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.all(24 * scale),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.howToPlayTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  Wrap(
                    spacing: 16 * scale,
                    runSpacing: 16 * scale,
                    alignment: WrapAlignment.center,
                    children: [
                      _HowToPlayCard(
                        highlight: _TutorialHighlight.row,
                        label: l10n.howToPlayRowRule,
                        frameColor: frameColor,
                      ),
                      _HowToPlayCard(
                        highlight: _TutorialHighlight.column,
                        label: l10n.howToPlayColumnRule,
                        frameColor: frameColor,
                      ),
                      _HowToPlayCard(
                        highlight: _TutorialHighlight.box,
                        label: l10n.howToPlayBoxRule,
                        frameColor: frameColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * scale),
                  Text(
                    l10n.howToPlayFooter,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(l10n.howToPlayAction),
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

class _HowToPlayCard extends StatelessWidget {
  final _TutorialHighlight highlight;
  final String label;
  final Color frameColor;

  const _HowToPlayCard({
    required this.highlight,
    required this.label,
    required this.frameColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = context.layoutScale;
    final colors = theme.colorScheme;

    return SizedBox(
      width: 140 * scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: frameColor,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(16 * scale),
            child: Padding(
              padding: EdgeInsets.all(12 * scale),
              child: AspectRatio(
                aspectRatio: 1,
                child: _TutorialGrid(
                  highlight: highlight,
                  highlightColor: colors.secondaryContainer,
                  gridColor: colors.outlineVariant.withOpacity(0.9),
                  strongGridColor: colors.outline,
                  numbersColor: colors.onSurface.withOpacity(0.9),
                  backgroundColor: colors.surface,
                ),
              ),
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _TutorialGrid extends StatelessWidget {
  final _TutorialHighlight highlight;
  final Color highlightColor;
  final Color gridColor;
  final Color strongGridColor;
  final Color numbersColor;
  final Color backgroundColor;

  const _TutorialGrid({
    required this.highlight,
    required this.highlightColor,
    required this.gridColor,
    required this.strongGridColor,
    required this.numbersColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TutorialGridPainter(
        highlight: highlight,
        highlightColor: highlightColor,
        gridColor: gridColor,
        strongGridColor: strongGridColor,
        numbersColor: numbersColor,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _TutorialGridPainter extends CustomPainter {
  final _TutorialHighlight highlight;
  final Color highlightColor;
  final Color gridColor;
  final Color strongGridColor;
  final Color numbersColor;
  final Color backgroundColor;

  _TutorialGridPainter({
    required this.highlight,
    required this.highlightColor,
    required this.gridColor,
    required this.strongGridColor,
    required this.numbersColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 9;
    final backgroundPaint = Paint()..color = backgroundColor;
    final rect = Offset.zero & size;
    canvas.drawRect(rect, backgroundPaint);

    Rect? highlightRect;
    switch (highlight) {
      case _TutorialHighlight.row:
        highlightRect = Rect.fromLTWH(0, cell * 3, size.width, cell);
        break;
      case _TutorialHighlight.column:
        highlightRect = Rect.fromLTWH(cell * 4, 0, cell, size.height);
        break;
      case _TutorialHighlight.box:
        highlightRect = Rect.fromLTWH(cell * 3, cell * 3, cell * 3, cell * 3);
        break;
    }

    if (highlightRect != null) {
      final paint = Paint()
        ..color = highlightColor.withOpacity(0.9)
        ..style = PaintingStyle.fill;
      canvas.drawRect(highlightRect, paint);
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    final textStyle = TextStyle(
      color: numbersColor,
      fontWeight: FontWeight.w600,
      fontSize: cell * 0.55,
    );

    for (var y = 0; y < 9; y++) {
      for (var x = 0; x < 9; x++) {
        final value = ((x + y) % 9) + 1;
        textPainter.text = TextSpan(text: '$value', style: textStyle);
        textPainter.layout();
        final dx = x * cell + (cell - textPainter.width) / 2;
        final dy = y * cell + (cell - textPainter.height) / 2;
        textPainter.paint(canvas, Offset(dx, dy));
      }
    }

    final thinPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;
    final thickPaint = Paint()
      ..color = strongGridColor
      ..strokeWidth = 2.0;

    for (var i = 0; i <= 9; i++) {
      final paint = i % 3 == 0 ? thickPaint : thinPaint;
      final dx = i * cell;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
      final dy = i * cell;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TutorialGridPainter oldDelegate) {
    return oldDelegate.highlight != highlight ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.strongGridColor != strongGridColor ||
        oldDelegate.numbersColor != numbersColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
