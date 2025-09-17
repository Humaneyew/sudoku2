import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    _selected = Difficulty.beginner;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final stats = app.statsFor(_selected);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика',
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
            title: 'Ігри',
            rows: [
              _StatRowData(
                icon: Icons.play_circle_outline,
                color: primary,
                label: 'Початі ігри',
                value: stats.gamesStarted.toString(),
              ),
              _StatRowData(
                icon: Icons.emoji_events_outlined,
                color: const Color(0xFF6ACB8A),
                label: 'Виграні ігри',
                value: stats.gamesWon.toString(),
              ),
              _StatRowData(
                icon: Icons.pie_chart_outline,
                color: const Color(0xFFE8736D),
                label: 'Відсоток перемог',
                value: stats.winRateText,
              ),
              _StatRowData(
                icon: Icons.shield_moon_outlined,
                color: const Color(0xFFFFB347),
                label: 'Завершення без помилок',
                value: stats.flawlessWins.toString(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _StatsSection(
            title: 'Час',
            rows: [
              _StatRowData(
                icon: Icons.timer_outlined,
                color: primary,
                label: 'Кращий час',
                value: stats.bestTimeText,
              ),
              _StatRowData(
                icon: Icons.hourglass_bottom,
                color: const Color(0xFF6D7392),
                label: 'Середній час',
                value: stats.averageTimeText,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _StatsSection(
            title: 'Серія',
            rows: [
              _StatRowData(
                icon: Icons.bolt_outlined,
                color: const Color(0xFFFB923C),
                label: 'Поточна серія',
                value: stats.currentStreak.toString(),
              ),
              _StatRowData(
                icon: Icons.auto_graph_outlined,
                color: primary,
                label: 'Найкраща серія',
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
    final primary = theme.colorScheme.primary;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final diff in Difficulty.values)
          ChoiceChip(
            label: Text(diff.title),
            selected: diff == selected,
            onSelected: (_) => onChanged(diff),
            selectedColor: primary,
            labelStyle: TextStyle(
              color: diff == selected ? Colors.white : const Color(0xFF4C5472),
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: const Color(0xFFE0ECFF),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x121B1D3A),
            blurRadius: 18,
            offset: Offset(0, 12),
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
                  color: theme.dividerColor?.withOpacity(0.4),
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
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2437),
            ),
          ),
        ),
        Text(
          data.value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
