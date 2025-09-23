import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'models.dart';
import 'stats_format.dart';
import 'layout/layout_scale.dart';

const double _statsSectionRadiusValue = 28.0;
const double _statIconRadiusValue = 16.0;

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
    final scale = context.layoutScale;
    final stats = context.select<AppState, _DifficultyStatsView>((app) {
      final data = app.statsFor(_selected);
      final formatted = StatsFormatter.formatNumbers(data, l10n.localeName);
      return _DifficultyStatsView.from(data, formatted);
    });

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 24 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize:
                  (theme.textTheme.headlineSmall?.fontSize ?? 24) * scale,
            ),
          ),
          SizedBox(height: 16 * scale),
          _DifficultySelector(
            selected: _selected,
            onChanged: (diff) => setState(() => _selected = diff),
          ),
          SizedBox(height: 24 * scale),
          _StatsSection(
            title: l10n.statsGamesSection,
            rows: [
              _StatRowData(
                icon: Icons.play_circle_outline,
                color: primary,
                label: l10n.statsGamesStarted,
                value: stats.gamesStartedText,
              ),
              _StatRowData(
                icon: Icons.emoji_events_outlined,
                color: winsAccent,
                label: l10n.statsGamesWon,
                value: stats.gamesWonText,
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
                value: stats.flawlessWinsText,
              ),
            ],
          ),
          SizedBox(height: 24 * scale),
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
          SizedBox(height: 24 * scale),
          _StatsSection(
            title: l10n.statsStreakSection,
            rows: [
              _StatRowData(
                icon: Icons.bolt_outlined,
                color: currentStreakAccent,
                label: l10n.statsCurrentStreak,
                value: stats.currentStreakText,
              ),
              _StatRowData(
                icon: Icons.auto_graph_outlined,
                color: winsAccent,
                label: l10n.statsBestStreak,
                value: stats.bestStreakText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyStatsView {
  final String gamesStartedText;
  final String gamesWonText;
  final String flawlessWinsText;
  final String winRateText;
  final String bestTimeText;
  final String averageTimeText;
  final String currentStreakText;
  final String bestStreakText;

  const _DifficultyStatsView({
    required this.gamesStartedText,
    required this.gamesWonText,
    required this.flawlessWinsText,
    required this.winRateText,
    required this.bestTimeText,
    required this.averageTimeText,
    required this.currentStreakText,
    required this.bestStreakText,
  });

  factory _DifficultyStatsView.from(
    DifficultyStats stats,
    StatsFormatResult formatted,
  ) {
    return _DifficultyStatsView(
      gamesStartedText: formatted.gamesStarted,
      gamesWonText: formatted.gamesWon,
      flawlessWinsText: formatted.flawlessWins,
      winRateText: stats.winRateText,
      bestTimeText: stats.bestTimeText,
      averageTimeText: stats.averageTimeText,
      currentStreakText: formatted.currentStreak,
      bestStreakText: formatted.bestStreak,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _DifficultyStatsView &&
            other.gamesStartedText == gamesStartedText &&
            other.gamesWonText == gamesWonText &&
            other.flawlessWinsText == flawlessWinsText &&
            other.winRateText == winRateText &&
            other.bestTimeText == bestTimeText &&
            other.averageTimeText == averageTimeText &&
            other.currentStreakText == currentStreakText &&
            other.bestStreakText == bestStreakText;
  }

  @override
  int get hashCode => Object.hash(
        gamesStartedText,
        gamesWonText,
        flawlessWinsText,
        winRateText,
        bestTimeText,
        averageTimeText,
        currentStreakText,
        bestStreakText,
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
    final scale = context.layoutScale;
    return Wrap(
      spacing: 8 * scale,
      runSpacing: 8 * scale,
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
              fontSize:
                  (theme.textTheme.labelLarge?.fontSize ?? 14) * scale,
            ),
            backgroundColor: cs.surfaceVariant,
            side: BorderSide(
              color: diff == selected ? cs.primary : cs.outlineVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(18 * scale),
              ),
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
    final scale = context.layoutScale;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(_statsSectionRadiusValue * scale),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 18 * scale,
            offset: Offset(0, 12 * scale),
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
              fontSize:
                  (theme.textTheme.titleMedium?.fontSize ?? 20) * scale,
            ),
          ),
          SizedBox(height: 16 * scale),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _StatRow(
              key: ValueKey('stats-row-${rows[index].label}'),
              data: rows[index],
            ),
            separatorBuilder: (context, _) => Padding(
              padding: EdgeInsets.symmetric(vertical: 12 * scale),
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
    final scale = context.layoutScale;
    return Row(
      children: [
        Container(
          width: 46 * scale,
          height: 46 * scale,
          decoration: BoxDecoration(
            color: data.color.withOpacity(0.12),
            borderRadius:
                BorderRadius.circular(_statIconRadiusValue * scale),
          ),
          child: Icon(
            data.icon,
            color: data.color,
            size: 24 * scale,
          ),
        ),
        SizedBox(width: 16 * scale),
        Expanded(
          child: Text(
            data.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              fontSize:
                  (theme.textTheme.bodyMedium?.fontSize ?? 14) * scale,
            ),
          ),
        ),
        Text(
          data.value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.primary,
            fontSize:
                (theme.textTheme.titleMedium?.fontSize ?? 20) * scale,
          ),
        ),
      ],
    );
  }
}
