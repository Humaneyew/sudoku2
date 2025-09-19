import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../flutter_gen/gen_l10n/app_localizations.dart';
import '../game_page.dart';
import '../models.dart';
import '../theme.dart';

class ChampionshipPage extends StatelessWidget {
  const ChampionshipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final colors = theme.extension<SudokuColors>()!;
    final l10n = AppLocalizations.of(context)!;

    const difficulties = [
      Difficulty.novice,
      Difficulty.medium,
      Difficulty.high,
      Difficulty.expert,
      Difficulty.master,
    ];

    final rounds = difficulties
        .map(
          (difficulty) => _ChampionshipRoundData(
            difficulty: difficulty,
            description: l10n.championshipRoundDescriptionPlaceholder,
            badgeLabel: difficulty.shortLabel(l10n),
          ),
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.championshipTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: colors.championshipChallengeGradient,
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  l10n.championshipScore(0),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final round = rounds[index];
                    return _ChampionshipRoundCard(
                      key: ValueKey('round-$index'),
                      data: round,
                      onPlay: () => _startRound(context, round.difficulty),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: rounds.length,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startRound(BuildContext context, Difficulty difficulty) {
    final app = context.read<AppState>();
    app.startGame(difficulty);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }
}

class _ChampionshipRoundData {
  final Difficulty difficulty;
  final String description;
  final String? badgeLabel;

  const _ChampionshipRoundData({
    required this.difficulty,
    required this.description,
    this.badgeLabel,
  });
}

class _ChampionshipRoundCard extends StatelessWidget {
  final _ChampionshipRoundData data;
  final VoidCallback onPlay;

  const _ChampionshipRoundCard({
    super.key,
    required this.data,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
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
            children: [
              Expanded(
                child: Text(
                  data.difficulty.title(l10n),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (data.badgeLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      cs.primary.withOpacity(0.12),
                      cs.surface,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Text(
                    data.badgeLabel!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
              child: Text(
                l10n.playAction,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
