import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
              const _ChampionshipHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: _LeaderboardSection(
                  localeName: l10n.localeName,
                  meLabel: l10n.meLabel,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startChampionshipGame(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                  ),
                  child: Text(
                    l10n.play,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startChampionshipGame(BuildContext context) {
    final championship = context.read<ChampionshipModel>();
    final rounds = championship.rounds;
    ChampionshipRound? target;
    for (final round in rounds) {
      if (round.status == ChampionshipRoundStatus.inProgress) {
        target = round;
        break;
      }
    }
    target ??= rounds.firstWhere(
      (round) => round.status != ChampionshipRoundStatus.completed,
      orElse: () => rounds.first,
    );

    championship.startRound(target.difficulty);
    final app = context.read<AppState>();
    app.startGame(target.difficulty);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }
}

class _ChampionshipHeader extends StatelessWidget {
  const _ChampionshipHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<SudokuColors>()!;
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Selector<ChampionshipModel, int>(
      selector: (_, model) => model.myScore,
      builder: (context, score, _) {
        final formatted = _ScoreFormatter.format(l10n.localeName, score);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.championshipTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ) ??
                    TextStyle(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cs.onPrimary.withOpacity(0.12),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  l10n.totalScore(formatted),
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w600,
                      ) ??
                      TextStyle(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w600,
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

class _LeaderboardSection extends StatelessWidget {
  final String localeName;
  final String meLabel;

  const _LeaderboardSection({
    required this.localeName,
    required this.meLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ChampionshipModel, Leaderboard>(
      selector: (_, model) => model.leaderboard,
      builder: (context, leaderboard, _) {
        return Selector<ChampionshipModel, int>(
          selector: (_, model) => model.myRank,
          builder: (context, rank, __) {
            return Selector<ChampionshipModel, int>(
              selector: (_, model) => model.myScore,
              builder: (context, score, ___) {
                return _LeaderboardListView(
                  leaderboard: leaderboard,
                  myRank: rank,
                  myScore: score,
                  localeName: localeName,
                  meLabel: meLabel,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LeaderboardListView extends StatelessWidget {
  final Leaderboard leaderboard;
  final int myRank;
  final int myScore;
  final String localeName;
  final String meLabel;

  const _LeaderboardListView({
    required this.leaderboard,
    required this.myRank,
    required this.myScore,
    required this.localeName,
    required this.meLabel,
  });

  @override
  Widget build(BuildContext context) {
    final opponents = leaderboard.opponents;
    final total = opponents.length + 1;
    final insertionIndex = (myRank.clamp(1, total)) - 1;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: total,
      itemBuilder: (context, index) {
        final isLast = index == total - 1;
        if (index == insertionIndex) {
          return _MyLeaderboardRow(
            key: const ValueKey('leaderboard-me'),
            rank: index + 1,
            score: myScore,
            label: meLabel,
            localeName: localeName,
            isLast: isLast,
          );
        }

        final opponentIndex = index > insertionIndex ? index - 1 : index;
        final opponent = opponents[opponentIndex];
        return _OpponentRow(
          key: ValueKey(opponent.id),
          rank: index + 1,
          opponent: opponent,
          localeName: localeName,
          isLast: isLast,
        );
      },
    );
  }
}

class _OpponentRow extends StatelessWidget {
  final Opponent opponent;
  final int rank;
  final String localeName;
  final bool isLast;

  const _OpponentRow({
    super.key,
    required this.opponent,
    required this.rank,
    required this.localeName,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: _LeaderboardRowContent(
        rank: rank,
        name: opponent.name,
        score: opponent.score,
        localeName: localeName,
        emphasize: false,
      ),
    );
  }
}

class _MyLeaderboardRow extends StatefulWidget {
  final int rank;
  final int score;
  final String label;
  final String localeName;
  final bool isLast;

  const _MyLeaderboardRow({
    super.key,
    required this.rank,
    required this.score,
    required this.label,
    required this.localeName,
    required this.isLast,
  });

  @override
  State<_MyLeaderboardRow> createState() => _MyLeaderboardRowState();
}

class _MyLeaderboardRowState extends State<_MyLeaderboardRow> {
  bool _highlight = false;
  Timer? _timer;

  @override
  void didUpdateWidget(covariant _MyLeaderboardRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score > oldWidget.score) {
      _timer?.cancel();
      setState(() {
        _highlight = true;
      });
      _timer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _highlight = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final baseColor = Color.alphaBlend(cs.primary.withOpacity(0.08), cs.surface);
    final highlightColor =
        Color.alphaBlend(cs.primary.withOpacity(0.18), cs.surface);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _highlight ? highlightColor : baseColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _highlight ? cs.primary : cs.primary.withOpacity(0.5),
          width: 1.2,
        ),
      ),
      child: _LeaderboardRowContent(
        rank: widget.rank,
        name: widget.label,
        score: widget.score,
        localeName: widget.localeName,
        emphasize: true,
      ),
    );
  }
}

class _LeaderboardRowContent extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final String localeName;
  final bool emphasize;

  const _LeaderboardRowContent({
    required this.rank,
    required this.name,
    required this.score,
    required this.localeName,
    required this.emphasize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final rankStyle = theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: emphasize ? cs.primary : cs.onSurface,
        ) ??
        TextStyle(
          fontWeight: FontWeight.w700,
          color: emphasize ? cs.primary : cs.onSurface,
          fontSize: 18,
        );
    final nameStyle = theme.textTheme.bodyLarge?.copyWith(
          fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
          color: cs.onSurface,
        ) ??
        TextStyle(
          fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
          color: cs.onSurface,
        );
    final scoreStyle = theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: emphasize ? cs.primary : cs.onSurfaceVariant,
        ) ??
        TextStyle(
          fontWeight: FontWeight.w600,
          color: emphasize ? cs.primary : cs.onSurfaceVariant,
        );

    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            '$rank',
            textAlign: TextAlign.center,
            style: rankStyle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: nameStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _ScoreFormatter.format(localeName, score),
          style: scoreStyle,
        ),
      ],
    );
  }
}

class _ScoreFormatter {
  _ScoreFormatter(this._formatter);

  final NumberFormat _formatter;

  static final Map<String, _ScoreFormatter> _cache = {};

  static String format(String localeName, int value) {
    final cached = _cache[localeName];
    if (cached != null) {
      return cached._formatter.format(value);
    }
    final formatter = NumberFormat.decimalPattern(localeName);
    final wrapper = _ScoreFormatter(formatter);
    _cache[localeName] = wrapper;
    return wrapper._formatter.format(value);
  }
}
