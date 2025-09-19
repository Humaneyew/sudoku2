import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../flutter_gen/gen_l10n/app_localizations.dart';
import '../game_page.dart';
import '../models.dart';
import '../theme.dart';
import 'championship_model.dart';

class ChampionshipPage extends StatelessWidget {
  const ChampionshipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChampionshipModel>(
      builder: (context, championship, _) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final colors = theme.extension<SudokuColors>()!;
        final l10n = AppLocalizations.of(context)!;

        final rounds = championship.rounds
            .map(
              (round) => _ChampionshipRoundData(
                difficulty: round.difficulty,
                status: round.status,
                description: l10n.championshipRoundDescriptionPlaceholder,
                badgeLabel: round.difficulty.shortLabel(l10n),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                          onAction:
                              round.status == ChampionshipRoundStatus.completed
                                  ? null
                                  : () => _startRound(context, round.difficulty),
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
      },
    );
  }

  void _startRound(BuildContext context, Difficulty difficulty) {
    context.read<ChampionshipModel>().startRound(difficulty);
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
  final ChampionshipRoundStatus status;
  final String description;
  final String? badgeLabel;

  const _ChampionshipRoundData({
    required this.difficulty,
    required this.status,
    required this.description,
    this.badgeLabel,
  });
}

class _ChampionshipRoundCard extends StatelessWidget {
  final _ChampionshipRoundData data;
  final VoidCallback? onAction;

  const _ChampionshipRoundCard({
    super.key,
    required this.data,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    Widget actionChild;
    switch (data.status) {
      case ChampionshipRoundStatus.notStarted:
      case ChampionshipRoundStatus.inProgress:
        final callback = onAction;
        if (callback == null) {
          actionChild = const SizedBox.shrink();
          break;
        }
        final label = data.status == ChampionshipRoundStatus.notStarted
            ? l10n.playAction
            : l10n.continueAction;
        actionChild = ElevatedButton(
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
        break;
      case ChampionshipRoundStatus.completed:
        actionChild = Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              cs.primary.withOpacity(0.12),
              cs.surface,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: cs.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.championshipRoundCompletedLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
        break;
    }

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            child: actionChild,
          ),
        ],
      ),
    );
  }
}
