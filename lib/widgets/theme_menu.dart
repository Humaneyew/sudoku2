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
    final brightness = MediaQuery.platformBrightnessOf(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Consumer<AppState>(
          builder: (context, app, _) {
            final activeTheme = app.resolvedTheme(brightness);
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
                Wrap(
                  spacing: 14,
                  children: [
                    for (final option in SudokuTheme.values)
                      _ThemeCircle(
                        option: option,
                        active: option == activeTheme,
                        onTap: () => app.setTheme(option),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: app.syncWithSystemTheme,
                  onChanged: app.setSyncWithSystemTheme,
                  title: Text(l10n.themeSyncWithSystem),
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
                  children: [
                    Text(
                      'A',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: app.fontScale,
                        min: AppState.minFontScale,
                        max: AppState.maxFontScale,
                        divisions: 8,
                        onChanged: app.setFontScale,
                      ),
                    ),
                    Text(
                      'A',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
        width: 52,
        height: 52,
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: baseColor,
              ),
            ),
            if (active)
              const Icon(
                Icons.check,
                color: Colors.white,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
