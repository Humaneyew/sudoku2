import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'models.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  late Difficulty _selected;

  @override
  void initState() {
    super.initState();
    _selected = Difficulty.novice;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final stats = app.statsFor(_selected);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = scheme.primary;
    Color blend(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;
    final winsAccent = scheme.secondary;
    final rateAccent = blend(scheme.error, scheme.secondary, 0.5);
    final flawlessAccent = blend(scheme.primary, scheme.onSurface, 0.3);
    final averageTimeAccent = blend(scheme.primary, scheme.onSurface, 0.4);
    final currentStreakAccent = blend(scheme.error, scheme.secondary, 0.35);
    final l10n = AppLocalizations.of(context)!;

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
                value: stats.gamesStarted.toString(),
              ),
              _StatRowData(
                icon: Icons.emoji_events_outlined,
                color: winsAccent,
                label: l10n.statsGamesWon,
                value: stats.gamesWon.toString(),
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
                value: stats.flawlessWins.toString(),
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
                value: stats.currentStreak.toString(),
              ),
              _StatRowData(
                icon: Icons.auto_graph_outlined,
                color: winsAccent,
                label: l10n.statsBestStreak,
                value: stats.bestStreak.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final diff in Difficulty.values)
          ChoiceChip(
            label: Text(diff.title(l10n)),
            selected: diff == selected,
            onSelected: (_) => onChanged(diff),
            selectedColor: scheme.primary,
            checkmarkColor: scheme.onPrimary,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              color: diff == selected ? scheme.onPrimary : scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: scheme.surfaceVariant,
            side: BorderSide(
              color: diff == selected ? scheme.primary : scheme.outlineVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
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
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
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
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < rows.length; i++) ...[
            _StatRow(data: rows[i]),
            if (i != rows.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  color: scheme.outlineVariant,
                ),
              ),
          ],
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

  const _StatRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: data.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(data.icon, color: data.color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            data.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
        Text(
          data.value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }
}
