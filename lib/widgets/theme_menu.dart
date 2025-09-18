import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import '../models.dart';
import '../theme.dart';

Future<void> showThemeMenu(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const _ThemeDialog(),
  );
}

class _ThemeDialog extends StatelessWidget {
  const _ThemeDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Consumer<AppState>(
          builder: (context, app, _) {
            final activeTheme = app.resolvedTheme();
            const themeOptions = [
              SudokuTheme.white,
              SudokuTheme.cream,
              SudokuTheme.green,
              SudokuTheme.black,
            ];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.themeSectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final option in themeOptions)
                      _ThemeCircle(
                        option: option,
                        active: option == activeTheme,
                        onTap: () => app.setTheme(option),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.themeFontSize,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'A',
                      style: TextStyle(
                        fontSize: AppState.minFontSizeSp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: app.fontSizeSp,
                        min: AppState.minFontSizeSp,
                        max: AppState.maxFontSizeSp,
                        divisions: AppState.fontSizeOptionsSp.length - 1,
                        onChanged: (value) =>
                            app.setFontSizeSp(value, save: false),
                        onChangeEnd: app.setFontSizeSp,
                      ),
                    ),
                    Text(
                      'A',
                      style: TextStyle(
                        fontSize: AppState.maxFontSizeSp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${app.fontSizeSp.round()} sp',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThemeCircle extends StatelessWidget {
  final SudokuTheme option;
  final bool active;
  final VoidCallback onTap;

  const _ThemeCircle({
    required this.option,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final baseColor = themePreviewColor(option);
    final borderColor = active ? scheme.primary : scheme.outlineVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: active ? 3 : 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: baseColor,
              ),
            ),
            if (active)
              Icon(
                Icons.check,
                color: scheme.onPrimary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
