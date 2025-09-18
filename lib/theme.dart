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
    background: const Color(0xFFF7FAFF),
    surface: Colors.white,
    primary: const Color(0xFF2563EB),
    onPrimary: Colors.white,
    onSurface: const Color(0xFF172036),
    outline: const Color(0xFFDDE5F6),
    outlineVariant: const Color(0xFFE8EDF9),
    colors: const SudokuColors(
      boardInner: Colors.white,
      boardBorder: Color(0xFFC7D3F4),
      selectedCell: Color(0xFFD9E7FF),
      sameNumberCell: Color(0xFFF1F5FF),
      noteColor: Color(0xFF7C8CB2),
      headerButtonBackground: Colors.white,
      headerButtonIcon: Color(0xFF2563EB),
      actionButtonActiveBackground: Color(0xFFE1ECFF),
      actionButtonActiveBorder: Color(0xFF90B5FF),
      actionButtonBadgeColor: Color(0xFF1D4ED8),
      numberPadBackground: Colors.white,
      numberPadBorder: Color(0xFFE2E8F7),
      numberPadSelectedBackground: Color(0xFFC6DAFF),
      numberPadSelectedBorder: Color(0xFF1D4ED8),
      numberPadHighlightBackground: Color(0xFFE7F0FF),
      numberPadHighlightBorder: Color(0xFF9AB7FF),
      numberPadDisabledBackground: Color(0xFFF2F4FB),
      numberPadDisabledText: Color(0xFFA9B2C7),
      numberPadRemaining: Color(0xFF8893AD),
      numberPadRemainingHighlight: Color(0xFF1D4ED8),
      shadowColor: Color(0x141B1D3A),
    ),
  ),
  SudokuTheme.cream: _ThemeConfig(
    brightness: Brightness.light,
    background: const Color(0xFFF8F0DE),
    surface: const Color(0xFFFFF7E8),
    primary: const Color(0xFF3E8B6D),
    onPrimary: Colors.white,
    onSurface: const Color(0xFF5A4529),
    outline: const Color(0xFFE8DCC3),
    outlineVariant: const Color(0xFFF2E7CF),
    colors: const SudokuColors(
      boardInner: Color(0xFFFFFBF2),
      boardBorder: Color(0xFFE0D2B5),
      selectedCell: Color(0xFFF2E3BF),
      sameNumberCell: Color(0xFFF9EED6),
      noteColor: Color(0xFFB08F5A),
      headerButtonBackground: Color(0xFFFFFBF2),
      headerButtonIcon: Color(0xFF2F7457),
      actionButtonActiveBackground: Color(0xFFDDECD8),
      actionButtonActiveBorder: Color(0xFF8AB89A),
      actionButtonBadgeColor: Color(0xFF3E8B6D),
      numberPadBackground: Color(0xFFFFFBF2),
      numberPadBorder: Color(0xFFE6D9C2),
      numberPadSelectedBackground: Color(0xFFD2E6D7),
      numberPadSelectedBorder: Color(0xFF2F7457),
      numberPadHighlightBackground: Color(0xFFEAF3E6),
      numberPadHighlightBorder: Color(0xFFA0C3AC),
      numberPadDisabledBackground: Color(0xFFF0E4C8),
      numberPadDisabledText: Color(0xFFB79B67),
      numberPadRemaining: Color(0xFFB39663),
      numberPadRemainingHighlight: Color(0xFF2F7457),
      shadowColor: Color(0x1A7B5E2F),
    ),
  ),
  SudokuTheme.green: _ThemeConfig(
    brightness: Brightness.light,
    background: const Color(0xFFE6F7F1),
    surface: const Color(0xFFF3FBF7),
    primary: const Color(0xFF2F8D6A),
    onPrimary: Colors.white,
    onSurface: const Color(0xFF153D2A),
    outline: const Color(0xFFCFE7DF),
    outlineVariant: const Color(0xFFE2F1EC),
    colors: const SudokuColors(
      boardInner: Color(0xFFFBFFFD),
      boardBorder: Color(0xFFC5DED2),
      selectedCell: Color(0xFFCFEFE0),
      sameNumberCell: Color(0xFFE5F7EC),
      noteColor: Color(0xFF6F8F7F),
      headerButtonBackground: Color(0xFFFBFFFD),
      headerButtonIcon: Color(0xFF2F8D6A),
      actionButtonActiveBackground: Color(0xFFC9EAD8),
      actionButtonActiveBorder: Color(0xFF78B894),
      actionButtonBadgeColor: Color(0xFF2F8D6A),
      numberPadBackground: Color(0xFFFBFFFD),
      numberPadBorder: Color(0xFFD4E8DE),
      numberPadSelectedBackground: Color(0xFFC1E5D4),
      numberPadSelectedBorder: Color(0xFF1F7252),
      numberPadHighlightBackground: Color(0xFFE0F4EA),
      numberPadHighlightBorder: Color(0xFF8AC4A4),
      numberPadDisabledBackground: Color(0xFFE9F4ED),
      numberPadDisabledText: Color(0xFFA8BCB0),
      numberPadRemaining: Color(0xFF779C86),
      numberPadRemainingHighlight: Color(0xFF1F7252),
      shadowColor: Color(0x14304933),
    ),
  ),
  SudokuTheme.black: _ThemeConfig(
    brightness: Brightness.dark,
    background: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
    primary: const Color(0xFF3D82FF),
    onPrimary: Colors.white,
    onSurface: const Color(0xFFE0E0E0),
    outline: const Color(0xFF2A2A2A),
    outlineVariant: const Color(0xFF242424),
    colors: const SudokuColors(
      boardInner: Color(0xFF1A1A1A),
      boardBorder: Color(0xFF2C2C2C),
      selectedCell: Color(0xFF2C3E5F),
      sameNumberCell: Color(0xFF202B3D),
      noteColor: Color(0xFFB3B9C6),
      headerButtonBackground: Color(0xFF1F2634),
      headerButtonIcon: Color(0xFF8EB6FF),
      actionButtonActiveBackground: Color(0xFF233349),
      actionButtonActiveBorder: Color(0xFF3D82FF),
      actionButtonBadgeColor: Color(0xFF3D82FF),
      numberPadBackground: Color(0xFF1E1E1E),
      numberPadBorder: Color(0xFF2A2A2A),
      numberPadSelectedBackground: Color(0xFF2F4060),
      numberPadSelectedBorder: Color(0xFF3D82FF),
      numberPadHighlightBackground: Color(0xFF242F43),
      numberPadHighlightBorder: Color(0xFF4D6EB5),
      numberPadDisabledBackground: Color(0xFF161616),
      numberPadDisabledText: Color(0xFF5C636F),
      numberPadRemaining: Color(0xFF808894),
      numberPadRemainingHighlight: Color(0xFF3D82FF),
      shadowColor: Color(0x66000000),
    ),
  ),
  SudokuTheme.purple: _ThemeConfig(
    brightness: Brightness.dark,
    background: const Color(0xFF2B0040),
    surface: const Color(0xFF3B005A),
    primary: const Color(0xFF9B4DFF),
    onPrimary: Colors.white,
    onSurface: Colors.white,
    outline: const Color(0xFF5C1C8F),
    outlineVariant: const Color(0xFF4A1574),
    colors: const SudokuColors(
      boardInner: Color(0xFF3B005A),
      boardBorder: Color(0xFF5D1B8C),
      selectedCell: Color(0xFF5F1E94),
      sameNumberCell: Color(0xFF4C1876),
      noteColor: Color(0xFFE5C9FF),
      headerButtonBackground: Color(0xFF4A1574),
      headerButtonIcon: Color(0xFFCFB0FF),
      actionButtonActiveBackground: Color(0xFF61219A),
      actionButtonActiveBorder: Color(0xFF9B4DFF),
      actionButtonBadgeColor: Color(0xFFCFB0FF),
      numberPadBackground: Color(0xFF3B005A),
      numberPadBorder: Color(0xFF541B86),
      numberPadSelectedBackground: Color(0xFF6A25A6),
      numberPadSelectedBorder: Color(0xFFD6B5FF),
      numberPadHighlightBackground: Color(0xFF4F177E),
      numberPadHighlightBorder: Color(0xFFA365FF),
      numberPadDisabledBackground: Color(0xFF2D003F),
      numberPadDisabledText: Color(0xFF8F70C0),
      numberPadRemaining: Color(0xFFDAB9FF),
      numberPadRemainingHighlight: Color(0xFF9B4DFF),
      shadowColor: Color(0x99000000),
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
    cardTheme: CardThemeData(
      color: config.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    dialogTheme: DialogThemeData(
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
