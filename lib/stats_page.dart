import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'models.dart';

const BorderRadius _statsSectionRadius = BorderRadius.all(Radius.circular(28));
const BorderRadius _statIconRadius = BorderRadius.all(Radius.circular(16));

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsTitle),
        centerTitle: true,
      ),
      body: const SafeArea(
        bottom: false,
        child: StatsTab(),
      ),
    );
  }
}

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin<StatsTab> {
  late Difficulty _selected;

  @override
  void initState() {
    super.initState();
    _selected = Difficulty.novice;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final primary = cs.primary;
    Color blend(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;
    final winsAccent = cs.secondary;
    final rateAccent = blend(cs.error, cs.secondary, 0.5);
    final flawlessAccent = blend(cs.primary, cs.onSurface, 0.3);
    final averageTimeAccent = blend(cs.primary, cs.onSurface, 0.4);
    final currentStreakAccent = blend(cs.error, cs.secondary, 0.35);
    final l10n = AppLocalizations.of(context)!;
    final numberFormatter = NumberFormat.decimalPattern(l10n.localeName);
    final stats = context.select<AppState, _DifficultyStatsView>((app) {
      final data = app.statsFor(_selected);
      return _DifficultyStatsView.from(data);
    });
    final gamesStartedText = _formatStatNumber(numberFormatter, stats.gamesStarted);
    final gamesWonText = _formatStatNumber(numberFormatter, stats.gamesWon);
    final flawlessWinsText =
        _formatStatNumber(numberFormatter, stats.flawlessWins);
    final currentStreakText =
        _formatStatNumber(numberFormatter, stats.currentStreak);
    final bestStreakText =
        _formatStatNumber(numberFormatter, stats.bestStreak);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _DifficultySelector(
            selected: _selected,
            onChanged: (diff) => setState(() => _selected = diff),
          ),
          const SizedBox(height: 24),
          _StatsSection(
            title: l10n.statsGamesSection,
            rows: [
              _StatRowData(
                icon: Icons.play_circle_outline,
                color: primary,
                label: l10n.statsGamesStarted,
                value: gamesStartedText,
              ),
              _StatRowData(
                icon: Icons.emoji_events_outlined,
                color: winsAccent,
                label: l10n.statsGamesWon,
                value: gamesWonText,
              ),
              _StatRowData(
                icon: Icons.pie_chart_outline,
                color: rateAccent,
                label: l10n.statsWinRate,
                value: stats.winRateText,
              ),
              _StatRowData(
                icon: Icons.shield_moon_outlined,
                color: flawlessAccent,
                label: l10n.statsFlawless,
                value: flawlessWinsText,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _StatsSection(
            title: l10n.statsTimeSection,
            rows: [
              _StatRowData(
                icon: Icons.timer_outlined,
                color: primary,
                label: l10n.statsBestTime,
                value: stats.bestTimeText,
              ),
              _StatRowData(
                icon: Icons.hourglass_bottom,
                color: averageTimeAccent,
                label: l10n.statsAverageTime,
                value: stats.averageTimeText,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _StatsSection(
            title: l10n.statsStreakSection,
            rows: [
              _StatRowData(
                icon: Icons.bolt_outlined,
                color: currentStreakAccent,
                label: l10n.statsCurrentStreak,
                value: currentStreakText,
              ),
              _StatRowData(
                icon: Icons.auto_graph_outlined,
                color: winsAccent,
                label: l10n.statsBestStreak,
                value: bestStreakText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatStatNumber(NumberFormat formatter, int value) {
  return formatter.format(value);
}

class _DifficultyStatsView {
  final int gamesStarted;
  final int gamesWon;
  final int flawlessWins;
  final String winRateText;
  final String bestTimeText;
  final String averageTimeText;
  final int currentStreak;
  final int bestStreak;

  const _DifficultyStatsView({
    required this.gamesStarted,
    required this.gamesWon,
    required this.flawlessWins,
    required this.winRateText,
    required this.bestTimeText,
    required this.averageTimeText,
    required this.currentStreak,
    required this.bestStreak,
  });

  factory _DifficultyStatsView.from(DifficultyStats stats) {
    return _DifficultyStatsView(
      gamesStarted: stats.gamesStarted,
      gamesWon: stats.gamesWon,
      flawlessWins: stats.flawlessWins,
      winRateText: stats.winRateText,
      bestTimeText: stats.bestTimeText,
      averageTimeText: stats.averageTimeText,
      currentStreak: stats.currentStreak,
      bestStreak: stats.bestStreak,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _DifficultyStatsView &&
            other.gamesStarted == gamesStarted &&
            other.gamesWon == gamesWon &&
            other.flawlessWins == flawlessWins &&
            other.winRateText == winRateText &&
            other.bestTimeText == bestTimeText &&
            other.averageTimeText == averageTimeText &&
            other.currentStreak == currentStreak &&
            other.bestStreak == bestStreak;
  }

  @override
  int get hashCode => Object.hash(
        gamesStarted,
        gamesWon,
        flawlessWins,
        winRateText,
        bestTimeText,
        averageTimeText,
        currentStreak,
        bestStreak,
      );
}

class _DifficultySelector extends StatelessWidget {
  final Difficulty selected;
  final ValueChanged<Difficulty> onChanged;

  const _DifficultySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final diff in Difficulty.values)
          ChoiceChip(
            key: ValueKey('stats-diff-${diff.name}'),
            label: Text(diff.title(l10n)),
            selected: diff == selected,
            onSelected: (_) => onChanged(diff),
            selectedColor: cs.primary,
            checkmarkColor: cs.onPrimary,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              color: diff == selected ? cs.onPrimary : cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: cs.surfaceVariant,
            side: BorderSide(
              color: diff == selected ? cs.primary : cs.outlineVariant,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  final String title;
  final List<_StatRowData> rows;

  const _StatsSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: _statsSectionRadius,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _StatRow(
              key: ValueKey('stats-row-${rows[index].label}'),
              data: rows[index],
            ),
            separatorBuilder: (context, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: cs.outlineVariant,
              ),
            ),
            itemCount: rows.length,
          ),
        ],
      ),
    );
  }
}

class _StatRowData {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatRowData({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
}

class _StatRow extends StatelessWidget {
  final _StatRowData data;

  const _StatRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: data.color.withOpacity(0.12),
            borderRadius: _statIconRadius,
          ),
          child: Icon(data.icon, color: data.color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            data.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ),
        Text(
          data.value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
      ],
    );
  }
}
