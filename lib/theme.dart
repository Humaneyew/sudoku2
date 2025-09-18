import 'package:flutter/material.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

/// Список доступных цветовых тем приложения.
enum SudokuTheme { white, cream, green, black, purple }

extension SudokuThemeL10n on SudokuTheme {
  /// Название темы для отображения пользователю.
  String label(AppLocalizations l10n) {
    switch (this) {
      case SudokuTheme.white:
        return l10n.themeWhite;
      case SudokuTheme.cream:
        return l10n.themeCream;
      case SudokuTheme.green:
        return l10n.themeGreen;
      case SudokuTheme.black:
        return l10n.themeBlack;
      case SudokuTheme.purple:
        return l10n.themePurple;
    }
  }
}

/// Дополнительные цвета, используемые в интерфейсе судоку.
class SudokuColors extends ThemeExtension<SudokuColors> {
  final Color boardInner;
  final Color boardBorder;
  final Color selectedCell;
  final Color sameNumberCell;
  final Color noteColor;
  final Color headerButtonBackground;
  final Color headerButtonIcon;
  final Color actionButtonActiveBackground;
  final Color actionButtonActiveBorder;
  final Color actionButtonBadgeColor;
  final Color numberPadBackground;
  final Color numberPadBorder;
  final Color numberPadSelectedBackground;
  final Color numberPadSelectedBorder;
  final Color numberPadHighlightBackground;
  final Color numberPadHighlightBorder;
  final Color numberPadDisabledBackground;
  final Color numberPadDisabledText;
  final Color numberPadRemaining;
  final Color numberPadRemainingHighlight;
  final Color shadowColor;

  const SudokuColors({
    required this.boardInner,
    required this.boardBorder,
    required this.selectedCell,
    required this.sameNumberCell,
    required this.noteColor,
    required this.headerButtonBackground,
    required this.headerButtonIcon,
    required this.actionButtonActiveBackground,
    required this.actionButtonActiveBorder,
    required this.actionButtonBadgeColor,
    required this.numberPadBackground,
    required this.numberPadBorder,
    required this.numberPadSelectedBackground,
    required this.numberPadSelectedBorder,
    required this.numberPadHighlightBackground,
    required this.numberPadHighlightBorder,
    required this.numberPadDisabledBackground,
    required this.numberPadDisabledText,
    required this.numberPadRemaining,
    required this.numberPadRemainingHighlight,
    required this.shadowColor,
  });

  @override
  ThemeExtension<SudokuColors> copyWith({
    Color? boardInner,
    Color? boardBorder,
    Color? selectedCell,
    Color? sameNumberCell,
    Color? noteColor,
    Color? headerButtonBackground,
    Color? headerButtonIcon,
    Color? actionButtonActiveBackground,
    Color? actionButtonActiveBorder,
    Color? actionButtonBadgeColor,
    Color? numberPadBackground,
    Color? numberPadBorder,
    Color? numberPadSelectedBackground,
    Color? numberPadSelectedBorder,
    Color? numberPadHighlightBackground,
    Color? numberPadHighlightBorder,
    Color? numberPadDisabledBackground,
    Color? numberPadDisabledText,
    Color? numberPadRemaining,
    Color? numberPadRemainingHighlight,
    Color? shadowColor,
  }) {
    return SudokuColors(
      boardInner: boardInner ?? this.boardInner,
      boardBorder: boardBorder ?? this.boardBorder,
      selectedCell: selectedCell ?? this.selectedCell,
      sameNumberCell: sameNumberCell ?? this.sameNumberCell,
      noteColor: noteColor ?? this.noteColor,
      headerButtonBackground:
          headerButtonBackground ?? this.headerButtonBackground,
      headerButtonIcon: headerButtonIcon ?? this.headerButtonIcon,
      actionButtonActiveBackground:
          actionButtonActiveBackground ?? this.actionButtonActiveBackground,
      actionButtonActiveBorder:
          actionButtonActiveBorder ?? this.actionButtonActiveBorder,
      actionButtonBadgeColor:
          actionButtonBadgeColor ?? this.actionButtonBadgeColor,
      numberPadBackground: numberPadBackground ?? this.numberPadBackground,
      numberPadBorder: numberPadBorder ?? this.numberPadBorder,
      numberPadSelectedBackground: numberPadSelectedBackground ??
          this.numberPadSelectedBackground,
      numberPadSelectedBorder:
          numberPadSelectedBorder ?? this.numberPadSelectedBorder,
      numberPadHighlightBackground: numberPadHighlightBackground ??
          this.numberPadHighlightBackground,
      numberPadHighlightBorder:
          numberPadHighlightBorder ?? this.numberPadHighlightBorder,
      numberPadDisabledBackground: numberPadDisabledBackground ??
          this.numberPadDisabledBackground,
      numberPadDisabledText:
          numberPadDisabledText ?? this.numberPadDisabledText,
      numberPadRemaining: numberPadRemaining ?? this.numberPadRemaining,
      numberPadRemainingHighlight: numberPadRemainingHighlight ??
          this.numberPadRemainingHighlight,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  ThemeExtension<SudokuColors> lerp(
    covariant ThemeExtension<SudokuColors>? other,
    double t,
  ) {
    if (other is! SudokuColors) {
      return this;
    }

    Color _lerp(Color a, Color b) => Color.lerp(a, b, t) ?? b;

    return SudokuColors(
      boardInner: _lerp(boardInner, other.boardInner),
      boardBorder: _lerp(boardBorder, other.boardBorder),
      selectedCell: _lerp(selectedCell, other.selectedCell),
      sameNumberCell: _lerp(sameNumberCell, other.sameNumberCell),
      noteColor: _lerp(noteColor, other.noteColor),
      headerButtonBackground:
          _lerp(headerButtonBackground, other.headerButtonBackground),
      headerButtonIcon: _lerp(headerButtonIcon, other.headerButtonIcon),
      actionButtonActiveBackground: _lerp(
        actionButtonActiveBackground,
        other.actionButtonActiveBackground,
      ),
      actionButtonActiveBorder:
          _lerp(actionButtonActiveBorder, other.actionButtonActiveBorder),
      actionButtonBadgeColor:
          _lerp(actionButtonBadgeColor, other.actionButtonBadgeColor),
      numberPadBackground:
          _lerp(numberPadBackground, other.numberPadBackground),
      numberPadBorder: _lerp(numberPadBorder, other.numberPadBorder),
      numberPadSelectedBackground: _lerp(
        numberPadSelectedBackground,
        other.numberPadSelectedBackground,
      ),
      numberPadSelectedBorder:
          _lerp(numberPadSelectedBorder, other.numberPadSelectedBorder),
      numberPadHighlightBackground: _lerp(
        numberPadHighlightBackground,
        other.numberPadHighlightBackground,
      ),
      numberPadHighlightBorder:
          _lerp(numberPadHighlightBorder, other.numberPadHighlightBorder),
      numberPadDisabledBackground: _lerp(
        numberPadDisabledBackground,
        other.numberPadDisabledBackground,
      ),
      numberPadDisabledText:
          _lerp(numberPadDisabledText, other.numberPadDisabledText),
      numberPadRemaining:
          _lerp(numberPadRemaining, other.numberPadRemaining),
      numberPadRemainingHighlight: _lerp(
        numberPadRemainingHighlight,
        other.numberPadRemainingHighlight,
      ),
      shadowColor: _lerp(shadowColor, other.shadowColor),
    );
  }
}

class _ThemeConfig {
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color primary;
  final Color onPrimary;
  final Color onSurface;
  final Color outline;
  final Color outlineVariant;
  final SudokuColors colors;

  const _ThemeConfig({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.onSurface,
    required this.outline,
    required this.outlineVariant,
    required this.colors,
  });
}

final Map<SudokuTheme, _ThemeConfig> _themeConfigs = {
  SudokuTheme.white: _ThemeConfig(
    brightness: Brightness.light,
    background: const Color(0xFFEAF2FF),
    surface: Colors.white,
    primary: const Color(0xFF3B82F6),
    onPrimary: Colors.white,
    onSurface: const Color(0xFF1F2437),
    outline: const Color(0xFFE1E6F5),
    outlineVariant: const Color(0xFFE9ECF6),
    colors: const SudokuColors(
      boardInner: Colors.white,
      boardBorder: Color(0xFFBFC9E6),
      selectedCell: Color(0xFFD6EAF8),
      sameNumberCell: Color(0xFFEAF2FB),
      noteColor: Color(0xFF96A0C4),
      headerButtonBackground: Colors.white,
      headerButtonIcon: Color(0xFF3B82F6),
      actionButtonActiveBackground: Color(0xFFE0F0FF),
      actionButtonActiveBorder: Color(0xFF9CC8FF),
      actionButtonBadgeColor: Color(0xFF3B82F6),
      numberPadBackground: Colors.white,
      numberPadBorder: Color(0xFFE2E5F3),
      numberPadSelectedBackground: Color(0xFFC7DBFF),
      numberPadSelectedBorder: Color(0xFF3B82F6),
      numberPadHighlightBackground: Color(0xFFE6F0FF),
      numberPadHighlightBorder: Color(0xFF9DBAFD),
      numberPadDisabledBackground: Color(0xFFF3F5FB),
      numberPadDisabledText: Color(0xFFB0B6C6),
      numberPadRemaining: Color(0xFF9AA3B9),
      numberPadRemainingHighlight: Color(0xFF3B82F6),
      shadowColor: Color(0x141B1D3A),
    ),
  ),
  SudokuTheme.cream: _ThemeConfig(
    brightness: Brightness.light,
    background: const Color(0xFFF5EFD7),
    surface: const Color(0xFFFFF4E1),
    primary: const Color(0xFF3F8F73),
    onPrimary: Colors.white,
    onSurface: const Color(0xFF5C4628),
    outline: const Color(0xFFE5D8BC),
    outlineVariant: const Color(0xFFF0E5CC),
    colors: const SudokuColors(
      boardInner: Color(0xFFFFFBF0),
      boardBorder: Color(0xFFDCCCA5),
      selectedCell: Color(0xFFF3E2B8),
      sameNumberCell: Color(0xFFF8EDD0),
      noteColor: Color(0xFFB69B63),
      headerButtonBackground: Color(0xFFFFFBF0),
      headerButtonIcon: Color(0xFF3F8F73),
      actionButtonActiveBackground: Color(0xFFDDEAD5),
      actionButtonActiveBorder: Color(0xFF8CB99F),
      actionButtonBadgeColor: Color(0xFF3F8F73),
      numberPadBackground: Color(0xFFFFFBF0),
      numberPadBorder: Color(0xFFE6D8BC),
      numberPadSelectedBackground: Color(0xFFCCE3D8),
      numberPadSelectedBorder: Color(0xFF3F8F73),
      numberPadHighlightBackground: Color(0xFFE6F1EA),
      numberPadHighlightBorder: Color(0xFF9CC1AF),
      numberPadDisabledBackground: Color(0xFFF0E4C7),
      numberPadDisabledText: Color(0xFFB79C67),
      numberPadRemaining: Color(0xFFB79C67),
      numberPadRemainingHighlight: Color(0xFF3F8F73),
      shadowColor: Color(0x1A7B5E2F),
    ),
  ),
  SudokuTheme.green: _ThemeConfig(
    brightness: Brightness.light,
    background: const Color(0xFFE4F2E1),
    surface: const Color(0xFFF4FAF2),
    primary: const Color(0xFF2F855A),
    onPrimary: Colors.white,
    onSurface: const Color(0xFF1E3A29),
    outline: const Color(0xFFC9D9C5),
    outlineVariant: const Color(0xFFDCE8DA),
    colors: const SudokuColors(
      boardInner: Color(0xFFF9FFF6),
      boardBorder: Color(0xFFBBD3B8),
      selectedCell: Color(0xFFD4EFD4),
      sameNumberCell: Color(0xFFE6F7E5),
      noteColor: Color(0xFF6B8F72),
      headerButtonBackground: Color(0xFFF9FFF6),
      headerButtonIcon: Color(0xFF2F855A),
      actionButtonActiveBackground: Color(0xFFCAEAD7),
      actionButtonActiveBorder: Color(0xFF7EBB92),
      actionButtonBadgeColor: Color(0xFF2F855A),
      numberPadBackground: Color(0xFFF9FFF6),
      numberPadBorder: Color(0xFFD5E6D2),
      numberPadSelectedBackground: Color(0xFFC5E8D4),
      numberPadSelectedBorder: Color(0xFF2F855A),
      numberPadHighlightBackground: Color(0xFFE0F4E6),
      numberPadHighlightBorder: Color(0xFF8BC5A0),
      numberPadDisabledBackground: Color(0xFFE9F4E7),
      numberPadDisabledText: Color(0xFFA7BBA7),
      numberPadRemaining: Color(0xFF7FA084),
      numberPadRemainingHighlight: Color(0xFF2F855A),
      shadowColor: Color(0x14304933),
    ),
  ),
  SudokuTheme.black: _ThemeConfig(
    brightness: Brightness.dark,
    background: const Color(0xFF080B14),
    surface: const Color(0xFF151A26),
    primary: const Color(0xFF3B82F6),
    onPrimary: Colors.white,
    onSurface: const Color(0xFFE5E9F5),
    outline: const Color(0xFF27304B),
    outlineVariant: const Color(0xFF1F263D),
    colors: const SudokuColors(
      boardInner: Color(0xFF121828),
      boardBorder: Color(0xFF23304B),
      selectedCell: Color(0xFF1F2F4A),
      sameNumberCell: Color(0xFF182339),
      noteColor: Color(0xFF8AA2CF),
      headerButtonBackground: Color(0xFF1A2234),
      headerButtonIcon: Color(0xFF5EA0FF),
      actionButtonActiveBackground: Color(0xFF1E2E4A),
      actionButtonActiveBorder: Color(0xFF3B82F6),
      actionButtonBadgeColor: Color(0xFF5EA0FF),
      numberPadBackground: Color(0xFF151A26),
      numberPadBorder: Color(0xFF1F263D),
      numberPadSelectedBackground: Color(0xFF1E2E4A),
      numberPadSelectedBorder: Color(0xFF3B82F6),
      numberPadHighlightBackground: Color(0xFF192338),
      numberPadHighlightBorder: Color(0xFF4361A8),
      numberPadDisabledBackground: Color(0xFF101623),
      numberPadDisabledText: Color(0xFF394463),
      numberPadRemaining: Color(0xFF5D6787),
      numberPadRemainingHighlight: Color(0xFF5EA0FF),
      shadowColor: Color(0x66000000),
    ),
  ),
  SudokuTheme.purple: _ThemeConfig(
    brightness: Brightness.dark,
    background: const Color(0xFF2E1A47),
    surface: const Color(0xFF382358),
    primary: const Color(0xFF9F7AEA),
    onPrimary: Colors.white,
    onSurface: const Color(0xFFE9DFFF),
    outline: const Color(0xFF463066),
    outlineVariant: const Color(0xFF412C60),
    colors: const SudokuColors(
      boardInner: Color(0xFF331F52),
      boardBorder: Color(0xFF4B2F73),
      selectedCell: Color(0xFF4A2C77),
      sameNumberCell: Color(0xFF3E275F),
      noteColor: Color(0xFFBBA4D8),
      headerButtonBackground: Color(0xFF3C275C),
      headerButtonIcon: Color(0xFFB99CFF),
      actionButtonActiveBackground: Color(0xFF4A2E72),
      actionButtonActiveBorder: Color(0xFF9F7AEA),
      actionButtonBadgeColor: Color(0xFFB99CFF),
      numberPadBackground: Color(0xFF382358),
      numberPadBorder: Color(0xFF412C60),
      numberPadSelectedBackground: Color(0xFF4A2E72),
      numberPadSelectedBorder: Color(0xFF9F7AEA),
      numberPadHighlightBackground: Color(0xFF3E275F),
      numberPadHighlightBorder: Color(0xFF845FD3),
      numberPadDisabledBackground: Color(0xFF2B1A42),
      numberPadDisabledText: Color(0xFF6E5A8C),
      numberPadRemaining: Color(0xFF9F86C5),
      numberPadRemainingHighlight: Color(0xFFB99CFF),
      shadowColor: Color(0x80000000),
    ),
  ),
};

ThemeData buildSudokuTheme(SudokuTheme theme) {
  final config = _themeConfigs[theme]!;
  final scheme = ColorScheme.fromSeed(
    seedColor: config.primary,
    brightness: config.brightness,
  ).copyWith(
    primary: config.primary,
    onPrimary: config.onPrimary,
    secondary: config.primary,
    onSecondary: config.onPrimary,
    tertiary: config.primary,
    onTertiary: config.onPrimary,
    background: config.background,
    onBackground: config.onSurface,
    surface: config.surface,
    onSurface: config.onSurface,
    surfaceVariant: Color.alphaBlend(
      config.onSurface.withOpacity(0.08),
      config.surface,
    ),
    onSurfaceVariant: config.onSurface.withOpacity(0.72),
    outline: config.outline,
    outlineVariant: config.outlineVariant,
    error: const Color(0xFFE74C3C),
    onError: Colors.white,
    surfaceTint: Colors.transparent,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: config.brightness,
    scaffoldBackgroundColor: config.background,
    shadowColor: config.colors.shadowColor,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'SF Pro Display',
      bodyColor: config.onSurface,
      displayColor: config.onSurface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: config.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: config.onSurface,
      elevation: 0,
      titleTextStyle: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: config.onSurface,
      ),
    ),
    cardColor: config.surface,
    cardTheme: CardTheme(
      color: config.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: config.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
      backgroundColor: config.surface,
      selectedItemColor: config.primary,
      unselectedItemColor:
          config.onSurface.withOpacity(config.brightness == Brightness.dark
              ? 0.5
              : 0.6),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    switchTheme: base.switchTheme.copyWith(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return config.primary;
        }
        return config.onSurface.withOpacity(0.4);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return config.primary.withOpacity(0.35);
        }
        return config.onSurface.withOpacity(0.15);
      }),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: config.primary,
      inactiveTrackColor: config.onSurface.withOpacity(0.2),
      thumbColor: config.primary,
      overlayColor: config.primary.withOpacity(0.12),
    ),
    extensions: [config.colors],
  );
}

/// Цвет, который используется для предпросмотра темы в меню выбора.
Color themePreviewColor(SudokuTheme theme) {
  return _themeConfigs[theme]!.primary;
}
