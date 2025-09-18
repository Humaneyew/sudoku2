import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'game_page.dart';
import 'models.dart';
import 'settings_page.dart';
import 'stats_page.dart';
import 'theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
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
        onChanged: (value) => setState(() => _index = value),
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

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final theme = Theme.of(context);
    final difficulty = app.featuredStatsDifficulty;
    final stats = app.statsFor(difficulty);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _TopBar(
              onSettingsTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _ChallengeCarousel(
            battleWinRate: app.battleWinRate,
            championshipScore: app.championshipScore,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _DailyChain(streak: app.dailyStreak),
                const SizedBox(height: 18),
                _ProgressCard(
                  stats: stats,
                  onNewGame: () => _openDifficultySheet(context),
                  onContinue: app.hasUnfinishedGame
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GamePage()),
                        )
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
    final difficulty = await showModalBottomSheet<Difficulty>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final items = Difficulty.values;
        final selected = app.featuredStatsDifficulty;
        final sheetL10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;

        return SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  sheetL10n.selectDifficultyTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ...List.generate(items.length, (index) {
                  final diff = items[index];
                  final stats = app.statsFor(diff);
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < items.length - 1 ? 12.0 : 0.0,
                    ),
                    child: _DifficultyTile(
                      title: diff.title(sheetL10n),
                      rankLabel: sheetL10n.rankLabel(stats.rank),
                      progress: stats.progressText,
                      isActive: diff == selected,
                      onTap: () => Navigator.pop(context, diff),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || difficulty == null) return;

    app.startGame(difficulty);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const _TopBar({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _CircleButton(icon: Icons.leaderboard_outlined, onTap: () {}),
        const SizedBox(width: 12),
        _CircleButton(icon: Icons.settings_outlined, onTap: onSettingsTap),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.headerButtonBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: colors.headerButtonIcon),
      ),
    );
  }
}

class _ChallengeCarousel extends StatelessWidget {
  final int battleWinRate;
  final int championshipScore;

  const _ChallengeCarousel({
    required this.battleWinRate,
    required this.championshipScore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formatter = DateFormat('d MMMM', l10n.localeName);
    final today = formatter.format(DateTime.now());

    final cards = [
      _ChallengeCardData(
        title: l10n.navDaily,
        subtitle: today,
        buttonLabel: l10n.playAction,
        gradient: const [Color(0xFFFFF0B3), Color(0xFFFFC26F)],
        icon: Icons.emoji_events,
        onPressed: () {},
      ),
      _ChallengeCardData(
        title: l10n.championshipTitle,
        subtitle: l10n.championshipScore(championshipScore),
        buttonLabel: l10n.playAction,
        gradient: const [Color(0xFFFFB2D0), Color(0xFFE55D87)],
        icon: Icons.workspace_premium_outlined,
        onPressed: () {},
        badge: '2G',
      ),
      _ChallengeCardData(
        title: l10n.battleTitle,
        subtitle: l10n.battleWinRate(battleWinRate),
        buttonLabel: l10n.startAction,
        gradient: const [Color(0xFFCDE7FF), Color(0xFF3B82F6)],
        icon: Icons.sports_esports_outlined,
        onPressed: () {},
      ),
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 24.0;
    const cardSpacing = 16.0;
    const cardHeight = 196.0;
    final availableWidth = screenWidth - horizontalPadding * 2;
    final cardWidth = availableWidth.clamp(0.0, 360.0).toDouble();

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: _ChallengeCard(data: cards[index]),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: cardSpacing),
        itemCount: cards.length,
      ),
    );
  }
}

class _ChallengeCardData {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onPressed;
  final String? badge;

  const _ChallengeCardData({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.gradient,
    required this.icon,
    required this.onPressed,
    this.badge,
  });
}

class _ChallengeCard extends StatelessWidget {
  final _ChallengeCardData data;

  const _ChallengeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onPrimary = scheme.onPrimary;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: onPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: data.gradient.last, size: 22),
              ),
              const Spacer(),
              if (data.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: onPrimary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    data.badge!,
                    style: TextStyle(
                      color: onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
        ),
        const Spacer(),
        Text(
          data.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data.subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: onPrimary.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: onPrimary,
              foregroundColor: data.gradient.last,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            onPressed: data.onPressed,
            child: Text(
              data.buttonLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _DailyChain extends StatelessWidget {
  final int streak;

  const _DailyChain({required this.streak});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = scheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, color: accent),
          const SizedBox(width: 8),
          Text(
            l10n.dailyStreak,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Color.alphaBlend(accent.withOpacity(0.16), scheme.surface),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              streak.toString(),
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w600,
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

  const _ProgressCard({
    required this.stats,
    required this.onNewGame,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.rankProgress,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurface.withOpacity(0.68),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: stats.progressTarget == 0
                  ? 0
                  : stats.progressCurrent / stats.progressTarget,
              backgroundColor: scheme.primary.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.rankLabel(stats.rank),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          if (onContinue != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onContinue,
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.primary,
                  side: BorderSide(color: scheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  l10n.continueGame,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNewGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                l10n.newGame,
                style: const TextStyle(
                  fontSize: 16,
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

class _DifficultyTile extends StatelessWidget {
  final String title;
  final String rankLabel;
  final String progress;
  final bool isActive;
  final VoidCallback onTap;

  const _DifficultyTile({
    required this.title,
    required this.rankLabel,
    required this.progress,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = isActive
        ? Color.alphaBlend(scheme.primary.withOpacity(0.12), scheme.surface)
        : scheme.surface;
    final borderColor =
        isActive ? scheme.primary : scheme.outlineVariant;
    final titleColor = isActive ? scheme.primary : scheme.onSurface;
    final mutedColor = scheme.onSurface.withOpacity(0.68);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rankLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              progress,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mutedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChallengesTab extends StatelessWidget {
  const _DailyChallengesTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final l10n = AppLocalizations.of(context)!;
    final formatter = DateFormat('E', l10n.localeName);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.navDaily,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _DailyHeroCard(
            dateLabel: DateFormat('d MMMM', l10n.localeName).format(today),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.weeklyProgress,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final date in days)
                _DayProgress(
                  label: formatter.format(date),
                  day: date.day,
                  isToday: date.day == today.day,
                  completed: date.isBefore(today),
                ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            l10n.rewardsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _RewardTile(
            icon: Icons.favorite_outline,
            title: l10n.rewardNoMistakesTitle,
            reward: l10n.rewardExtraHearts(1),
          ),
          const SizedBox(height: 12),
          _RewardTile(
            icon: Icons.emoji_events_outlined,
            title: l10n.rewardThreeInRowTitle,
            reward: l10n.rewardUniqueTrophy,
          ),
          const SizedBox(height: 12),
          _RewardTile(
            icon: Icons.local_fire_department_outlined,
            title: l10n.rewardSevenDayTitle,
            reward: l10n.rewardStars(50),
          ),
        ],
      ),
    );
  }
}

class _DailyHeroCard extends StatelessWidget {
  final String dateLabel;

  const _DailyHeroCard({required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onPrimary = scheme.onPrimary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9AD3FF), Color(0xFF4E8BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              dateLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: onPrimary.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.todayPuzzle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: onPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.todayPuzzleDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: onPrimary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: onPrimary,
                foregroundColor: scheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.continueAction,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayProgress extends StatelessWidget {
  final String label;
  final int day;
  final bool isToday;
  final bool completed;

  const _DayProgress({
    required this.label,
    required this.day,
    required this.isToday,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final baseColor = isToday
        ? scheme.primary
        : completed
            ? scheme.secondary
            : scheme.outlineVariant;
    final background =
        Color.alphaBlend(baseColor.withOpacity(0.15), scheme.surface);
    final textColor =
        isToday || completed ? baseColor : scheme.onSurface.withOpacity(0.7);

    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            day.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String reward;

  const _RewardTile({
    required this.icon,
    required this.title,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          Text(
            reward,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
