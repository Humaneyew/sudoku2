import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'battle/battle_page.dart';
import 'game_page.dart';
import 'models.dart';
import 'settings_page.dart';
import 'stats_page.dart';
import 'theme.dart';
import 'championship/championship_model.dart';
import 'layout/layout_scale.dart';
import 'widgets/how_to_play_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
  }

  Future<void> _maybeShowTutorial() async {
    if (!mounted) {
      return;
    }
    final app = context.read<AppState>();
    if (app.tutorialSeen) {
      return;
    }
    final accepted = await showHowToPlayDialog(
      context,
      barrierDismissible: false,
    );
    if (!mounted) {
      return;
    }
    if (accepted) {
      app.markTutorialSeen();
    }
  }

  void _onSelectTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(onOpenChallenge: () => _onSelectTab(1)),
      const _DailyChallengesTab(),
      const StatsTab(),
    ];

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: _BottomNavBar(
        index: _index,
        onChanged: _onSelectTab,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNavBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: index,
      onTap: onChanged,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_rounded),
          label: l10n.navHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_month_rounded),
          label: l10n.navDaily,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart_rounded),
          label: l10n.navStats,
        ),
      ],
    );
  }
}

class _HomeTab extends StatefulWidget {
  final VoidCallback onOpenChallenge;

  const _HomeTab({required this.onOpenChallenge});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final app = context.watch<AppState>();
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final size = media.size;
    final scale = context.layoutScale;
    final viewPadding = media.viewPadding;
    final safeWidth = math.max(0.0, size.width - viewPadding.left - viewPadding.right);
    final safeHeight = math.max(0.0, size.height - viewPadding.top - viewPadding.bottom);
    final isCompactHeight = safeHeight < 720;
    final isCompactWidth = safeWidth < 380;
    final horizontalPadding = (isCompactWidth ? 20.0 : 24.0) * scale;
    final verticalPadding = (isCompactHeight ? 20.0 : 24.0) * scale;
    final topSpacing = (isCompactHeight ? 20.0 : 24.0) * scale;
    final carouselSpacing = (isCompactHeight ? 24.0 : 32.0) * scale;
    final bodySpacing = (isCompactHeight ? 14.0 : 18.0) * scale;
    final difficulty = app.featuredStatsDifficulty;
    final stats = app.statsFor(difficulty);
    final l10n = AppLocalizations.of(context)!;

    final baseTitle = theme.textTheme.headlineSmall;
    final titleStyle = baseTitle?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5 * scale,
      fontSize: (baseTitle.fontSize ?? 24) * scale,
    );

    double titlePlaceholderHeight = 12 * scale;
    if (titleStyle != null) {
      final textPainter = TextPainter(
        text: TextSpan(text: l10n.appTitle, style: titleStyle),
        textDirection: Directionality.of(context),
      )..layout();
      titlePlaceholderHeight += textPainter.height;
    }

    final dailyContentTopSpacing = math.max(
      8.0 * scale,
      titlePlaceholderHeight - (isCompactHeight ? 12.0 : 16.0) * scale,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _TopBar(
              scale: scale,
              title: l10n.appTitle,
              titleStyle: titleStyle,
              onStatsTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsPage()),
              ),
              onSettingsTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
          ),
          SizedBox(height: topSpacing),
          _ChallengeCarousel(
            battleWinRate: app.battleWinRate,
            onOpenChallenge: widget.onOpenChallenge,
            onOpenBattle: () => _startBattle(context),
            horizontalPadding: horizontalPadding,
            scale: scale,
          ),
          SizedBox(height: carouselSpacing),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: dailyContentTopSpacing),
                _DailyChain(streak: app.dailyStreak, scale: scale),
                SizedBox(height: bodySpacing),
                _ProgressCard(
                  scale: scale,
                  stats: stats,
                  onNewGame: () => _openDifficultySheet(context),
                  onContinue: app.hasUnfinishedGame
                      ? () => _openCurrentGame(context)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDifficultySheet(BuildContext context) async {
    final app = context.read<AppState>();
    final bottomSheetScale = context.layoutScale;
    final result = await showModalBottomSheet<Difficulty>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32 * bottomSheetScale),
        ),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final palette = _DifficultySheetPalette.fromTheme(theme);
        final scale = context.layoutScale;
        final items = Difficulty.values;
        final selected = app.featuredStatsDifficulty;
        final sheetL10n = AppLocalizations.of(context)!;

        final tiles = <Widget>[];
        for (var index = 0; index < items.length; index++) {
          final diff = items[index];
          final stats = app.statsFor(diff);
          tiles.add(
            _DifficultyTile(
              key: ValueKey(_difficultyKey(diff)),
              title: diff.title(sheetL10n),
              rankLabel: sheetL10n.rankLabel(stats.rank),
              progressCurrent: stats.progressCurrent,
              progressTarget: stats.progressTarget,
              isActive: diff == selected,
              palette: palette,
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(
                    context,
                    diff,
                  );
                }
              },
              scale: scale,
            ),
          );
          if (index < items.length - 1) {
            tiles.add(SizedBox(height: 12 * scale));
          }
        }

        return SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24 * scale,
              16 * scale,
              24 * scale,
              32 * scale,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _DifficultySheetCloseButton(
                      palette: palette,
                      onPressed: () => Navigator.pop(context),
                      scale: scale,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    sheetL10n.selectDifficultyTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.titleColor,
                      fontSize:
                          (theme.textTheme.titleMedium?.fontSize ?? 20) * scale,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20 * scale),
                  ...tiles,
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!context.mounted || result == null) return;

    app.startGame(result);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }

  void _openCurrentGame(BuildContext context) {
    final app = context.read<AppState>();
    final mode = app.currentMode;
    if (mode == GameMode.battle) {
      final diff = app.currentDifficulty ?? app.featuredStatsDifficulty;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BattlePage(difficulty: diff)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GamePage()),
      );
    }
  }

  void _startBattle(BuildContext context) {
    final app = context.read<AppState>();
    final diff = app.currentDifficulty ?? app.featuredStatsDifficulty;
    app.startBattleGame(diff);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BattlePage(difficulty: diff)),
    );
  }
}

String _difficultyKey(Difficulty difficulty) {
  switch (difficulty) {
    case Difficulty.novice:
      return 'home-diff-beginner';
    case Difficulty.medium:
      return 'home-diff-intermediate';
    case Difficulty.high:
      return 'home-diff-advanced';
    case Difficulty.expert:
      return 'home-diff-expert';
    case Difficulty.master:
      return 'home-diff-master';
  }
}

class _TopBar extends StatelessWidget {
  final double scale;
  final String title;
  final TextStyle? titleStyle;
  final VoidCallback onStatsTap;
  final VoidCallback onSettingsTap;

  const _TopBar({
    required this.scale,
    required this.title,
    required this.titleStyle,
    required this.onStatsTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 12 * scale),
        _CircleButton(
          icon: Icons.leaderboard_outlined,
          onTap: onStatsTap,
          scale: scale,
        ),
        SizedBox(width: 12 * scale),
        _CircleButton(
          icon: Icons.settings_outlined,
          onTap: onSettingsTap,
          scale: scale,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double scale;

  const _CircleButton({required this.icon, required this.onTap, required this.scale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    return InkResponse(
      onTap: onTap,
      radius: 28 * scale,
      child: Container(
        width: 48 * scale,
        height: 48 * scale,
        decoration: BoxDecoration(
          color: colors.headerButtonBackground,
          borderRadius: BorderRadius.all(Radius.circular(24 * scale)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 12 * scale,
              offset: Offset(0, 6 * scale),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: colors.headerButtonIcon,
          size: 24 * scale,
        ),
      ),
    );
  }
}

void _startDailyChallengeGame(BuildContext context, DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final now = DateTime.now();
  final normalizedToday = DateTime(now.year, now.month, now.day);
  if (normalized.isAfter(normalizedToday)) {
    return;
  }
  final app = context.read<AppState>();
  app.startDailyChallenge(normalized);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const GamePage()),
  );
}

class _ChallengeCarousel extends StatelessWidget {
  final int battleWinRate;
  final VoidCallback onOpenChallenge;
  final VoidCallback onOpenBattle;
  final double horizontalPadding;
  final double scale;

  const _ChallengeCarousel({
    required this.battleWinRate,
    required this.onOpenChallenge,
    required this.onOpenBattle,
    required this.horizontalPadding,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final formatter = DateFormat('d MMMM', l10n.localeName);
    final now = DateTime.now();
    final normalizedToday = DateTime(now.year, now.month, now.day);
    final today = formatter.format(normalizedToday);
    final colors = theme.extension<SudokuColors>()!;
    final media = MediaQuery.of(context);

    final cards = <Widget>[
      _ChallengeCard(
        scale: scale,
        key: const ValueKey('challenge-card-daily'),
        data: _ChallengeCardData(
          title: l10n.navDaily,
          subtitle: today,
          buttonLabel: l10n.playAction,
          gradient: colors.dailyChallengeGradient,
          icon: Icons.emoji_events,
          onPressed: onOpenChallenge,
        ),
      ),
      Selector<ChampionshipModel, _ChampionshipCardVm>(
        selector: (_, model) => _ChampionshipCardVm.fromModel(model),
        builder: (context, vm, _) {
          return _ChampionshipCard(
            scale: scale,
            key: const ValueKey('challenge-card-championship'),
            score: vm.score,
            gradient: colors.championshipChallengeGradient,
            icon: Icons.workspace_premium_outlined,
            badge: '2G',
          );
        },
      ),
      _ChallengeCard(
        scale: scale,
        key: const ValueKey('challenge-card-battle'),
        data: _ChallengeCardData(
          title: l10n.battleTitle,
          subtitle: l10n.battleWinRate(battleWinRate),
          buttonLabel: l10n.playAction,
          gradient: colors.battleChallengeGradient,
          icon: Icons.sports_esports_outlined,
          onPressed: onOpenBattle,
        ),
      ),
    ];

    final screenWidth = media.size.width;
    final isCompactHeight = media.size.height < 720;
    final bool showTwoCards = screenWidth < 600;
    final double cardSpacing = 16.0 * scale;
    final double cardHeight = (isCompactHeight ? 184.0 : 196.0) * scale;
    final availableWidth = screenWidth - horizontalPadding * 2;
    final double maxCardWidth = 360.0 * scale;

    final double cardWidth;
    if (showTwoCards) {
      final widthForTwoCards = availableWidth - cardSpacing;
      if (widthForTwoCards > 0) {
        cardWidth = math.min(widthForTwoCards / 2, maxCardWidth);
      } else {
        cardWidth = availableWidth.clamp(0.0, maxCardWidth).toDouble();
      }
    } else {
      cardWidth = availableWidth.clamp(0.0, maxCardWidth).toDouble();
    }

    final listView = ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      clipBehavior: Clip.none,
      itemBuilder: (context, index) {
        return SizedBox(
          key: ValueKey('challenge-card-$index'),
          width: cardWidth,
          child: cards[index],
        );
      },
      separatorBuilder: (_, __) => SizedBox(width: cardSpacing),
      itemCount: cards.length,
    );

    if (theme.colorScheme.brightness != Brightness.dark) {
      return SizedBox(height: cardHeight, child: listView);
    }

    final backgroundColor = theme.scaffoldBackgroundColor;
    return SizedBox(
      height: cardHeight,
      child: Stack(
        children: [
          listView,
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 32 * scale,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      backgroundColor,
                      backgroundColor.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 32 * scale,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      backgroundColor.withOpacity(0),
                      backgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCardData {
  final String title;
  final String subtitle;
  final String? secondaryLine;
  final String buttonLabel;
  final LinearGradient gradient;
  final IconData icon;
  final VoidCallback onPressed;
  final String? badge;

  const _ChallengeCardData({
    required this.title,
    required this.subtitle,
    this.secondaryLine,
    required this.buttonLabel,
    required this.gradient,
    required this.icon,
    required this.onPressed,
    this.badge,
  });
}

class _ChallengeCardGeometry {
  final double padding;
  final double iconPadding;
  final double iconSize;
  final double badgeHorizontalPadding;
  final double badgeVerticalPadding;
  final double titleFontSize;
  final double subtitleFontSize;
  final double secondaryFontSize;
  final double subtitleSpacing;
  final double secondarySpacing;
  final double buttonSpacing;
  final double buttonHeight;
  final double buttonHorizontalPadding;

  const _ChallengeCardGeometry._({
    required this.padding,
    required this.iconPadding,
    required this.iconSize,
    required this.badgeHorizontalPadding,
    required this.badgeVerticalPadding,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.secondaryFontSize,
    required this.subtitleSpacing,
    required this.secondarySpacing,
    required this.buttonSpacing,
    required this.buttonHeight,
    required this.buttonHorizontalPadding,
  });

  factory _ChallengeCardGeometry.resolve(
    BoxConstraints constraints,
    double scale,
  ) {
    final safeScale = scale <= 0 ? 1.0 : scale;
    final height = constraints.maxHeight.isFinite
        ? constraints.maxHeight / safeScale
        : 0;
    final width = constraints.maxWidth.isFinite
        ? constraints.maxWidth / safeScale
        : 0;
    final isCompactHeight = height > 0 && height < 190;
    final isCompactWidth = width > 0 && width < 170;
    final compact = isCompactHeight || isCompactWidth;

    if (compact) {
      return _ChallengeCardGeometry._(
        padding: 16 * safeScale,
        iconPadding: 8 * safeScale,
        iconSize: 20 * safeScale,
        badgeHorizontalPadding: 9 * safeScale,
        badgeVerticalPadding: 3 * safeScale,
        titleFontSize: 16 * safeScale,
        subtitleFontSize: 13 * safeScale,
        secondaryFontSize: 12 * safeScale,
        subtitleSpacing: 2 * safeScale,
        secondarySpacing: 2 * safeScale,
        buttonSpacing: 14 * safeScale,
        buttonHeight: 36 * safeScale,
        buttonHorizontalPadding: 20 * safeScale,
      );
    }

    return _ChallengeCardGeometry._(
      padding: 20 * safeScale,
      iconPadding: 10 * safeScale,
      iconSize: 22 * safeScale,
      badgeHorizontalPadding: 10 * safeScale,
      badgeVerticalPadding: 4 * safeScale,
      titleFontSize: 18 * safeScale,
      subtitleFontSize: 14 * safeScale,
      secondaryFontSize: 13 * safeScale,
      subtitleSpacing: 4 * safeScale,
      secondarySpacing: 3 * safeScale,
      buttonSpacing: 18 * safeScale,
      buttonHeight: 40 * safeScale,
      buttonHorizontalPadding: 24 * safeScale,
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final _ChallengeCardData data;
  final double scale;

  const _ChallengeCard({Key? key, required this.data, required this.scale})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry = _ChallengeCardGeometry.resolve(constraints, scale);
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final onPrimary = cs.onPrimary;
        final isDark = cs.brightness == Brightness.dark;
        final accentColor = data.gradient.colors.last;
        final baseTextColor =
            isDark ? const Color(0xFFE0E0E0) : onPrimary;
        final secondaryTextColor = isDark
            ? const Color(0xFFBDBDBD)
            : onPrimary.withOpacity(0.7);
        final highlightTextColor = isDark
            ? const Color(0xFFE0E0E0)
            : onPrimary.withOpacity(0.85);

        final secondaryStyle = theme.textTheme.bodySmall?.copyWith(
              color: highlightTextColor,
              fontSize: geometry.secondaryFontSize,
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(
              color: highlightTextColor,
              fontSize: geometry.secondaryFontSize,
              fontWeight: FontWeight.w600,
            );

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(28 * scale)),
            color: isDark ? const Color(0xFF1E1E1E) : null,
            gradient: isDark ? null : data.gradient,
            boxShadow: [
              if (isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6 * scale,
                  offset: Offset(0, 4 * scale),
                )
              else
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 18 * scale,
                  offset: Offset(0, 10 * scale),
                ),
            ],
          ),
          padding: EdgeInsets.all(geometry.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(geometry.iconPadding),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      data.icon,
                      color: isDark ? baseTextColor : accentColor,
                      size: geometry.iconSize,
                    ),
                  ),
                  const Spacer(),
                  if (data.badge != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: geometry.badgeHorizontalPadding,
                        vertical: geometry.badgeVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : onPrimary.withOpacity(0.18),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30 * scale),
                        ),
                      ),
                      child: Text(
                        data.badge!,
                        style: TextStyle(
                          color: baseTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12 * scale,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                data.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: baseTextColor,
                  fontSize: geometry.titleFontSize,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: geometry.subtitleSpacing),
              Text(
                data.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor,
                  fontSize: geometry.subtitleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (data.secondaryLine != null) ...[
                SizedBox(height: geometry.secondarySpacing),
                Text(
                  data.secondaryLine!,
                  style: secondaryStyle,
                ),
              ],
              SizedBox(height: geometry.buttonSpacing),
              SizedBox(
                height: geometry.buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? accentColor : onPrimary,
                    foregroundColor: isDark ? Colors.white : accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(18 * scale),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: geometry.buttonHorizontalPadding,
                    ),
                  ),
                  onPressed: data.onPressed,
                  child: Text(
                    data.buttonLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChampionshipCard extends StatelessWidget {
  const _ChampionshipCard({
    Key? key,
    required this.score,
    required this.gradient,
    required this.icon,
    this.badge,
    required this.scale,
  }) : super(key: key);

  final int score;
  final LinearGradient gradient;
  final IconData icon;
  final String? badge;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry = _ChallengeCardGeometry.resolve(constraints, scale);
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final onPrimary = cs.onPrimary;
        final isDark = cs.brightness == Brightness.dark;
        final accentColor = gradient.colors.last;
        final baseTextColor =
            isDark ? const Color(0xFFE0E0E0) : onPrimary;
        final secondaryTextColor = isDark
            ? const Color(0xFFBDBDBD)
            : onPrimary.withOpacity(0.7);
        final l10n = AppLocalizations.of(context)!;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(28 * scale)),
            color: isDark ? const Color(0xFF1E1E1E) : null,
            gradient: isDark ? null : gradient,
            boxShadow: [
              if (isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6 * scale,
                  offset: Offset(0, 4 * scale),
                )
              else
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 18 * scale,
                  offset: Offset(0, 10 * scale),
                ),
            ],
          ),
          padding: EdgeInsets.all(geometry.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(geometry.iconPadding),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isDark ? baseTextColor : accentColor,
                      size: geometry.iconSize,
                    ),
                  ),
                  const Spacer(),
                  if (badge != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: geometry.badgeHorizontalPadding,
                        vertical: geometry.badgeVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : onPrimary.withOpacity(0.18),
                        borderRadius: BorderRadius.all(
                          Radius.circular(30 * scale),
                        ),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          color: baseTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12 * scale,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                l10n.championshipTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                      color: baseTextColor,
                      fontSize: geometry.titleFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: geometry.subtitleSpacing),
              Text(
                l10n.championshipScore(score),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor,
                  fontSize: geometry.subtitleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: geometry.buttonSpacing),
              SizedBox(
                height: geometry.buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? accentColor : onPrimary,
                    foregroundColor: isDark ? Colors.white : accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(18 * scale),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: geometry.buttonHorizontalPadding,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/championship');
                  },
                  child: Text(
                    l10n.play,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChampionshipCardVm {
  const _ChampionshipCardVm({
    required this.score,
  });

  final int score;

  factory _ChampionshipCardVm.fromModel(ChampionshipModel model) {
    return _ChampionshipCardVm(
      score: model.myScore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _ChampionshipCardVm && other.score == score;
  }

  @override
  int get hashCode => score.hashCode;
}

class _DailyChain extends StatelessWidget {
  final int streak;
  final double scale;

  const _DailyChain({required this.streak, required this.scale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final accent = cs.error;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.all(Radius.circular(20 * scale)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 16 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: accent,
            size: 20 * scale,
          ),
          SizedBox(width: 8 * scale),
          Text(
            l10n.dailyStreak,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              fontSize:
                  (theme.textTheme.bodyMedium?.fontSize ?? 14) * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10 * scale,
              vertical: 4 * scale,
            ),
            decoration: BoxDecoration(
              color: Color.alphaBlend(accent.withOpacity(0.16), cs.surface),
              borderRadius: BorderRadius.all(Radius.circular(16 * scale)),
            ),
            child: Text(
              streak.toString(),
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w600,
                fontSize: 14 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final DifficultyStats stats;
  final VoidCallback onNewGame;
  final VoidCallback? onContinue;
  final double scale;

  const _ProgressCard({
    required this.stats,
    required this.onNewGame,
    this.onContinue,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.all(Radius.circular(28 * scale)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 24 * scale,
            offset: Offset(0, 16 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.rankProgress,
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurface.withOpacity(0.68),
              fontSize:
                  (theme.textTheme.labelLarge?.fontSize ?? 14) * scale,
            ),
          ),
          SizedBox(height: 8 * scale),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(12 * scale)),
            child: LinearProgressIndicator(
              minHeight: 10 * scale,
              value: stats.progressTarget == 0
                  ? 0
                  : stats.progressCurrent / stats.progressTarget,
              backgroundColor: cs.primary.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                cs.primary,
              ),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            l10n.rankLabel(stats.rank),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              fontSize:
                  (theme.textTheme.bodyMedium?.fontSize ?? 14) * scale,
            ),
          ),
          SizedBox(height: 24 * scale),
          if (onContinue != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: const ValueKey('home-continue'),
                onPressed: onContinue,
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary),
                  padding:
                      EdgeInsets.symmetric(vertical: 18 * scale, horizontal: 8 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18 * scale)),
                  ),
                ),
                child: Text(
                  l10n.continueGame,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12 * scale),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNewGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 18 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18 * scale)),
                ),
              ),
              child: Text(
                l10n.newGame,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const double _difficultyTileRadiusValue = 20.0;
const double _difficultyProgressHeight = 6.0;
const Duration _difficultyProgressAnimationDuration =
    Duration(milliseconds: 320);

class _DifficultySheetPalette {
  final Color tileBackground;
  final Color tileActiveBackground;
  final Color badgeBackground;
  final Color badgeActiveBackground;
  final Color badgeTextColor;
  final Color badgeActiveTextColor;
  final Color progressTextColor;
  final Color titleColor;
  final Color closeBackground;
  final Color closeIconColor;
  final Color progressTrackColor;
  final Color progressTrackActiveColor;
  final Color progressFillColor;
  final Color progressFillActiveColor;

  const _DifficultySheetPalette({
    required this.tileBackground,
    required this.tileActiveBackground,
    required this.badgeBackground,
    required this.badgeActiveBackground,
    required this.badgeTextColor,
    required this.badgeActiveTextColor,
    required this.progressTextColor,
    required this.titleColor,
    required this.closeBackground,
    required this.closeIconColor,
    required this.progressTrackColor,
    required this.progressTrackActiveColor,
    required this.progressFillColor,
    required this.progressFillActiveColor,
  });

  factory _DifficultySheetPalette.fromTheme(ThemeData theme) {
    final cs = theme.colorScheme;
    final brightness = theme.brightness;

    Color overlay(Color color, double opacity) {
      return Color.alphaBlend(color.withOpacity(opacity), cs.surface);
    }

    if (brightness == Brightness.dark) {
      return _DifficultySheetPalette(
        tileBackground: overlay(cs.onSurface, 0.12),
        tileActiveBackground: overlay(cs.primary, 0.32),
        badgeBackground: overlay(cs.onSurface, 0.18),
        badgeActiveBackground: cs.primary,
        badgeTextColor: cs.onSurface.withOpacity(0.75),
        badgeActiveTextColor: cs.onPrimary,
        progressTextColor: cs.onSurfaceVariant,
        titleColor: cs.onSurface,
        closeBackground: overlay(cs.onSurface, 0.16),
        closeIconColor: cs.onSurfaceVariant,
        progressTrackColor: overlay(cs.onSurfaceVariant, 0.26),
        progressTrackActiveColor: overlay(cs.primary, 0.34),
        progressFillColor: cs.onSurface.withOpacity(0.55),
        progressFillActiveColor: cs.primary,
      );
    }

    return _DifficultySheetPalette(
      tileBackground: overlay(cs.onSurface, 0.04),
      tileActiveBackground: overlay(cs.primary, 0.18),
      badgeBackground: overlay(cs.onSurface, 0.06),
      badgeActiveBackground: cs.primary,
      badgeTextColor: cs.onSurface.withOpacity(0.65),
      badgeActiveTextColor: cs.onPrimary,
      progressTextColor: cs.onSurface.withOpacity(0.6),
      titleColor: cs.onSurface,
      closeBackground: overlay(cs.onSurface, 0.05),
      closeIconColor: cs.onSurfaceVariant,
      progressTrackColor: overlay(cs.onSurfaceVariant, 0.12),
      progressTrackActiveColor: overlay(cs.primary, 0.24),
      progressFillColor: overlay(cs.onSurface, 0.14),
      progressFillActiveColor: cs.primary,
    );
  }
}

class _DifficultySheetCloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  final _DifficultySheetPalette palette;
  final double scale;

  const _DifficultySheetCloseButton({
    required this.onPressed,
    required this.palette,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18 * scale),
      onTap: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          color: palette.closeBackground,
          borderRadius: BorderRadius.circular(18 * scale),
        ),
        child: SizedBox(
          width: 36 * scale,
          height: 36 * scale,
          child: Icon(
            Icons.close_rounded,
            size: 18 * scale,
            color: palette.closeIconColor,
          ),
        ),
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final String title;
  final String rankLabel;
  final int progressCurrent;
  final int progressTarget;
  final bool isActive;
  final _DifficultySheetPalette palette;
  final VoidCallback onTap;
  final double scale;

  const _DifficultyTile({
    super.key,
    required this.title,
    required this.rankLabel,
    required this.progressCurrent,
    required this.progressTarget,
    required this.isActive,
    required this.palette,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final safeTarget = progressTarget <= 0 ? 0 : progressTarget;
    final safeCurrent = safeTarget == 0
        ? 0
        : progressCurrent < 0
            ? 0
            : (progressCurrent > safeTarget ? safeTarget : progressCurrent);
    final progressText = safeTarget == 0 ? null : '$safeCurrent / $safeTarget';
    final progressValue =
        safeTarget == 0 ? 0.0 : safeCurrent / safeTarget;

    final background =
        isActive ? palette.tileActiveBackground : palette.tileBackground;
    final titleColor = palette.titleColor;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: titleColor,
          fontSize:
              (theme.textTheme.titleMedium?.fontSize ?? 18) * scale,
        ) ??
        TextStyle(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w600,
          color: titleColor,
        );

    final rankBackground =
        isActive ? palette.badgeActiveBackground : palette.badgeBackground;
    final rankColor =
        isActive ? palette.badgeActiveTextColor : palette.badgeTextColor;
    final rankStyle = theme.textTheme.labelLarge?.copyWith(
          color: rankColor,
          fontWeight: FontWeight.w700,
          fontSize:
              (theme.textTheme.labelLarge?.fontSize ?? 14) * scale,
        ) ??
        TextStyle(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w700,
          color: rankColor,
        );

    final progressColor = palette.progressTextColor;
    final progressStyle = theme.textTheme.bodySmall?.copyWith(
          color: progressColor,
          fontWeight: FontWeight.w600,
          fontSize:
              (theme.textTheme.bodySmall?.fontSize ?? 12) * scale,
        ) ??
        TextStyle(
          fontSize: 12 * scale,
          fontWeight: FontWeight.w600,
          color: progressColor,
        );

    final trackColor = isActive
        ? palette.progressTrackActiveColor
        : palette.progressTrackColor;
    final fillColor =
        isActive ? palette.progressFillActiveColor : palette.progressFillColor;

    final borderRadius =
        BorderRadius.circular(_difficultyTileRadiusValue * scale);

    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: background,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 17 * scale,
            vertical: 12.75 * scale,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 14 * scale),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale,
                          vertical: 5 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: rankBackground,
                          borderRadius: BorderRadius.all(
                            Radius.circular(999 * scale),
                          ),
                        ),
                        child: Text(
                          rankLabel,
                          style: rankStyle,
                        ),
                      ),
                      if (progressText != null) ...[
                        SizedBox(height: 4 * scale),
                        Text(
                          progressText,
                          style: progressStyle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (progressText != null) ...[
                SizedBox(height: 10 * scale),
                _DifficultyProgressBar(
                  progress: progressValue,
                  trackColor: trackColor,
                  fillColor: fillColor,
                  scale: scale,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyProgressBar extends StatelessWidget {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double scale;

  const _DifficultyProgressBar({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress =
        progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0).toDouble();
    final height = _difficultyProgressHeight * scale;

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final targetWidth = constraints.maxWidth * clampedProgress;
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: trackColor),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: _difficultyProgressAnimationDuration,
                    curve: Curves.easeInOut,
                    width: targetWidth,
                    height: height,
                    decoration: BoxDecoration(color: fillColor),
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


class _DailyChallengesTab extends StatefulWidget {
  const _DailyChallengesTab();

  @override
  State<_DailyChallengesTab> createState() => _DailyChallengesTabState();
}

class _DailyChallengesTabState extends State<_DailyChallengesTab>
    with
        SingleTickerProviderStateMixin<_DailyChallengesTab>,
        AutomaticKeepAliveClientMixin<_DailyChallengesTab> {
  late DateTime _visibleMonth;
  late int _preferredDay;
  DateTime? _selectedDate;
  bool _initialized = false;
  late final AnimationController _introController;
  late final Animation<double> _trophyScale;
  late final Animation<double> _trophyOpacity;
  late final Animation<Offset> _headerOffset;
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _calendarOffset;
  late final Animation<double> _calendarOpacity;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _preferredDay = now.day;
    _selectedDate = DateTime(now.year, now.month, now.day);

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _trophyScale = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutBack,
    );
    _trophyOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _headerOffset = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOut),
      ),
    );
    _headerOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.15, 0.65, curve: Curves.easeIn),
    );
    _calendarOffset = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );
    _calendarOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _introController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final active = context.read<AppState>().activeDailyChallengeDate;
    if (active != null) {
      _visibleMonth = DateTime(active.year, active.month);
      _preferredDay = active.day;
      _selectedDate = active;
    }
  }

  void _changeMonth(int delta) {
    final target = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    setState(() {
      _visibleMonth = DateTime(target.year, target.month);
      final resolved = _resolveSelectionForMonth(_visibleMonth);
      _selectedDate = resolved;
      if (resolved != null) {
        _preferredDay = resolved.day;
      }
    });
  }

  DateTime? _resolveSelectionForMonth(DateTime month) {
    final maxDay = _maxSelectableDay(month);
    if (maxDay == 0) {
      return null;
    }
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    var day = _preferredDay;
    if (day < 1) {
      day = 1;
    }
    if (day > daysInMonth) {
      day = daysInMonth;
    }
    if (day > maxDay) {
      day = maxDay;
    }
    return DateTime(month.year, month.month, day);
  }

  int _maxSelectableDay(DateTime month) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    if (month.year > normalizedToday.year ||
        (month.year == normalizedToday.year && month.month > normalizedToday.month)) {
      return 0;
    }
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    if (month.year == normalizedToday.year && month.month == normalizedToday.month) {
      return normalizedToday.day;
    }
    return days;
  }

  void _onSelect(DateTime date) {
    setState(() {
      _selectedDate = date;
      _preferredDay = date.day;
    });
  }

  void _startDaily(DateTime date) {
    _startDailyChallengeGame(context, date);
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final app = context.watch<AppState>();
    final sudokuTheme = app.resolvedTheme();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    final size = media.size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final heightForSizing =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? constraints.maxHeight
                : size.height;
        const minHeight = 560.0;
        const maxHeight = 880.0;
        final heightFactor = ((heightForSizing - minHeight) /
                (maxHeight - minHeight))
            .clamp(0.0, 1.0)
            .toDouble();

        final widthForSizing =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : size.width;
        const minWidth = 320.0;
        const maxWidth = 430.0;
        final widthFactor = ((widthForSizing - minWidth) /
                (maxWidth - minWidth))
            .clamp(0.0, 1.0)
            .toDouble();

        double lerpHeight(double small, double large) =>
            lerpDouble(small, large, heightFactor)!;
        double lerpWidth(double small, double large) =>
            lerpDouble(small, large, widthFactor)!;

        final horizontalPadding = lerpWidth(13.0, 28.0);
        final headerTopPadding = media.padding.top + lerpHeight(6.0, 36.0);
        final headerBottomPadding = lerpHeight(24.0, 132.0);
        final headerOverlap = lerpHeight(36.0, 68.0);
        final trophyDiameter = lerpHeight(54.0, 116.0);
        final trophyIconSize = lerpHeight(32.0, 64.0);
        final headerTrophySpacing = lerpHeight(4.0, 22.0);
        final headerTitleSpacing = lerpHeight(3.0, 14.0);
        final headerStatIconSize = lerpHeight(15.0, 26.0);
        final headerStatSpacing = lerpHeight(3.0, 10.0);
        final calendarVerticalPadding = lerpHeight(3.0, 32.0);
        final calendarHeaderSpacing = lerpHeight(4.0, 22.0);
        final calendarWeekdaySpacing = lerpHeight(3.0, 18.0);
        final calendarBottomSpacing = lerpHeight(4.0, 30.0);
        final playButtonPaddingV = lerpHeight(5.0, 20.0);
        final bottomSpacing = lerpHeight(4.0, 26.0);

        final today = DateTime.now();
        final normalizedToday = DateTime(today.year, today.month, today.day);
        final monthDays =
            DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
        final progress = app.completedDailyCount(_visibleMonth);
        const challengeGoal = 30;
        final headerProgress = progress.clamp(0, challengeGoal);

        final textScaleFactor = media.textScaleFactor;
        final extraTextScale =
            (textScaleFactor - 1.0).clamp(0.0, 2.0).toDouble();
        final baseCalendarHorizontal = lerpWidth(7.0, 18.0);
        final calendarHorizontalPadding =
            (baseCalendarHorizontal - 3 * extraTextScale)
                .clamp(6.0, baseCalendarHorizontal)
                .toDouble();
        final baseCalendarCrossSpacing = lerpWidth(3.0, 10.0);
        final calendarCrossSpacing =
            (baseCalendarCrossSpacing - 2.5 * extraTextScale)
                .clamp(2.0, baseCalendarCrossSpacing)
                .toDouble();
        final baseCalendarMainSpacing = lerpHeight(2.0, 12.0);
        final calendarMainSpacing =
            (baseCalendarMainSpacing - 2.0 * extraTextScale)
                .clamp(2.0, baseCalendarMainSpacing)
                .toDouble();

        final monthFormatter = DateFormat.MMMM(l10n.localeName);
        final rawMonthLabel = monthFormatter.format(_visibleMonth);
        final monthLabel =
            toBeginningOfSentenceCase(rawMonthLabel, l10n.localeName) ??
                rawMonthLabel;
        final monthHeaderFontFactor = lerpHeight(0.84, 1.0);
        final monthHeaderStyle = theme.textTheme.titleMedium
            ?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            )
            ?.apply(fontSizeFactor: monthHeaderFontFactor);

        final headerTitleFontFactor = lerpHeight(0.82, 1.0);
        final headerTitleStyle = theme.textTheme.headlineMedium
            ?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            )
            ?.apply(fontSizeFactor: headerTitleFontFactor);

        final headerScoreFontFactor = lerpHeight(0.86, 1.0);
        final headerScoreStyle = theme.textTheme.titleMedium
            ?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w700,
            )
            ?.apply(fontSizeFactor: headerScoreFontFactor);

        final playButtonFontFactor = lerpHeight(0.86, 1.0);

        final weekdayFormatter = DateFormat.E(l10n.localeName);
        final currentSelected = _selectedDate;

        final firstDayOfMonth =
            DateTime(_visibleMonth.year, _visibleMonth.month, 1);
        final leadingEmpty = (firstDayOfMonth.weekday + 6) % 7;
        final totalCells = ((leadingEmpty + monthDays + 6) ~/ 7) * 7;

        final canGoNext = !(_visibleMonth.year == normalizedToday.year &&
            _visibleMonth.month == normalizedToday.month);

        final canPlay =
            currentSelected != null && !currentSelected.isAfter(normalizedToday);

        final surfaceColor = cs.surface;
        final headerGradient = LinearGradient(
          colors: [
            cs.primary,
            Color.lerp(cs.primary, cs.onPrimary, 0.25) ?? cs.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

        return Container(
          color: cs.background,
          child: Padding(
            padding: EdgeInsets.only(bottom: media.padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    headerTopPadding,
                    horizontalPadding,
                    headerBottomPadding,
                  ),
                  decoration: BoxDecoration(
                    gradient: headerGradient,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _trophyOpacity,
                        child: ScaleTransition(
                          scale: _trophyScale,
                          child: Container(
                            width: trophyDiameter,
                            height: trophyDiameter,
                            decoration: BoxDecoration(
                              color: cs.onPrimary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              color: cs.onPrimary,
                              size: trophyIconSize,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: headerTrophySpacing),
                      FadeTransition(
                        opacity: _headerOpacity,
                        child: SlideTransition(
                          position: _headerOffset,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                l10n.navDaily,
                                textAlign: TextAlign.center,
                                style: headerTitleStyle,
                              ),
                              SizedBox(height: headerTitleSpacing),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: const Color(0xFFFFD54F),
                                    size: headerStatIconSize,
                                  ),
                                  SizedBox(width: headerStatSpacing),
                                  Text(
                                    '$headerProgress/$challengeGoal',
                                    style: headerScoreStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -headerOverlap),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: SlideTransition(
                      position: _calendarOffset,
                      child: FadeTransition(
                        opacity: _calendarOpacity,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                            calendarHorizontalPadding,
                            calendarVerticalPadding,
                            calendarHorizontalPadding,
                            calendarVerticalPadding,
                          ),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: const BorderRadius.all(Radius.circular(28)),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor,
                                blurRadius: 30,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.chevron_left_rounded),
                                    onPressed: () => _changeMonth(-1),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        monthLabel,
                                        style: monthHeaderStyle,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.chevron_right_rounded),
                                    onPressed:
                                        canGoNext ? () => _changeMonth(1) : null,
                                  ),
                                ],
                              ),
                              SizedBox(height: calendarHeaderSpacing),
                              Row(
                                children: List.generate(7, (index) {
                                  final label = weekdayFormatter
                                      .format(DateTime(2020, 1, 6 + index));
                                  return Expanded(
                                    key: ValueKey('weekday-$index'),
                                    child: Center(
                                      child: Text(
                                        label.toUpperCase(),
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(height: calendarWeekdaySpacing),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: totalCells,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: calendarMainSpacing,
                                  crossAxisSpacing: calendarCrossSpacing,
                                ),
                                itemBuilder: (context, index) {
                                  final day = index - leadingEmpty + 1;
                                  if (day < 1 || day > monthDays) {
                                    return const SizedBox.shrink();
                                  }
                                  final date = DateTime(
                                      _visibleMonth.year, _visibleMonth.month, day);
                                  final isToday =
                                      DateUtils.isSameDay(date, normalizedToday);
                                  final isPast = date.isBefore(normalizedToday);
                                  final locked = date.isAfter(normalizedToday);
                                  return AspectRatio(
                                    aspectRatio: 1,
                                    child: _CalendarDayButton(
                                      key:
                                          ValueKey('calendar-${date.toIso8601String()}'),
                                      date: date,
                                      selected: currentSelected != null &&
                                          DateUtils.isSameDay(currentSelected, date),
                                      today: isToday,
                                      past: isPast,
                                      completed: app.isDailyCompleted(date),
                                      locked: locked,
                                      sudokuTheme: sudokuTheme,
                                      onTap: locked ? null : () => _onSelect(date),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: calendarBottomSpacing),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: canPlay && currentSelected != null
                                      ? () => _startDaily(currentSelected)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cs.primary,
                                    foregroundColor: cs.onPrimary,
                                    padding: EdgeInsets.symmetric(
                                      vertical: playButtonPaddingV,
                                      horizontal: 16,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(22)),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    l10n.playAction,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: cs.onPrimary,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.1,
                                        )
                                        ?.apply(fontSizeFactor: playButtonFontFactor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: bottomSpacing),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CalendarDayButton extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final bool today;
  final bool past;
  final bool completed;
  final bool locked;
  final SudokuTheme sudokuTheme;
  final VoidCallback? onTap;

  const _CalendarDayButton({
    super.key,
    required this.date,
    required this.selected,
    required this.today,
    required this.past,
    required this.completed,
    required this.locked,
    required this.sudokuTheme,
    required this.onTap,
  });

  Color _resolveTextColor(ColorScheme scheme) {
    if (locked) {
      return scheme.onSurface.withOpacity(0.3);
    }
    if (selected) {
      return scheme.onPrimary;
    }
    if (completed || past) {
      switch (sudokuTheme) {
        case SudokuTheme.white:
          return Colors.black;
        case SudokuTheme.black:
          return Colors.white;
        case SudokuTheme.cream:
        case SudokuTheme.green:
          return scheme.secondary;
      }
    }
    return scheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textColor = _resolveTextColor(cs);
    final textStyle = (theme.textTheme.titleSmall ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w700,
      color: textColor,
    );
    final border = today
        ? Border.all(
            color: selected ? cs.onPrimary : cs.primary,
            width: 3,
          )
        : null;
    final Widget dayContent;
    if (completed) {
      dayContent = const Icon(
        Icons.star_rounded,
        color: Color(0xFFFFD700),
        size: 30,
      );
    } else {
      dayContent = Text(
        '${date.day}',
        style: textStyle,
        textAlign: TextAlign.center,
        softWrap: false,
      );
    }

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      scale: selected ? 1.08 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? cs.primary : Colors.transparent,
          border: border,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: locked ? null : onTap,
            child: SizedBox.expand(
              child: Center(child: dayContent),
            ),
          ),
        ),
      ),
    );
  }
}

