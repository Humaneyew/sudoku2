import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../flutter_gen/gen_l10n/app_localizations.dart';
import '../game_page.dart';
import '../models.dart';
import '../theme.dart';
import 'championship_model.dart';

const double _rowExtent = 56.0;

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
    final difficulty = championship.recommendedDifficulty;
    championship.startRound(difficulty);
    final app = context.read<AppState>();
    app.startGame(
      difficulty,
      mode: GameMode.championship,
    );
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
              const SizedBox(height: 12),
              const _NextPlaceIndicator(),
            ],
          ),
        );
      },
    );
  }
}

class _NextPlaceIndicator extends StatelessWidget {
  const _NextPlaceIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
          color: cs.onPrimary,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(
          color: cs.onPrimary,
          fontWeight: FontWeight.w600,
        );
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final duration = reduceMotion ? Duration.zero : const Duration(milliseconds: 260);
    final curve = reduceMotion ? Curves.linear : Curves.easeOutCubic;

    return Selector<ChampionshipModel, _NextProgressVm>(
      selector: (_, model) => _NextProgressVm.fromModel(model),
      builder: (context, vm, _) {
        final progressValue = vm.isTop ? 1.0 : vm.progress;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.isTop)
              Text(l10n.youAreTop, style: textStyle)
            else
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: vm.delta.toDouble()),
                duration: duration,
                curve: curve,
                builder: (context, value, child) {
                  final displayed = value.round();
                  return Text(l10n.toNextPlace(displayed), style: textStyle);
                },
              ),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progressValue),
              duration: duration,
              curve: curve,
              builder: (context, value, child) {
                final progress = reduceMotion ? progressValue : value.clamp(0.0, 1.0);
                return ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: cs.onPrimary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _NextProgressVm {
  const _NextProgressVm({
    required this.isTop,
    required this.delta,
    required this.progressPermille,
  });

  final bool isTop;
  final int delta;
  final int progressPermille;

  double get progress => progressPermille / 1000.0;

  static _NextProgressVm fromModel(ChampionshipModel model) {
    final snapshot = model.nextProgress();
    final progressPermille = (snapshot.progress.clamp(0.0, 1.0) * 1000).round();
    return _NextProgressVm(
      isTop: snapshot.isTop,
      delta: snapshot.deltaToNext,
      progressPermille: snapshot.isTop ? 1000 : progressPermille,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _NextProgressVm &&
        other.isTop == isTop &&
        other.delta == delta &&
        other.progressPermille == progressPermille;
  }

  @override
  int get hashCode => Object.hash(isTop, delta, progressPermille);
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
                return Selector<ChampionshipModel, bool>(
                  selector: (_, model) => model.autoScrollEnabled,
                  builder: (context, autoScroll, ____) {
                    return _LeaderboardListView(
                      leaderboard: leaderboard,
                      myRank: rank,
                      myScore: score,
                      localeName: localeName,
                      meLabel: meLabel,
                      autoScrollEnabled: autoScroll,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LeaderboardListView extends StatefulWidget {
  final Leaderboard leaderboard;
  final int myRank;
  final int myScore;
  final String localeName;
  final String meLabel;
  final bool autoScrollEnabled;

  const _LeaderboardListView({
    required this.leaderboard,
    required this.myRank,
    required this.myScore,
    required this.localeName,
    required this.meLabel,
    required this.autoScrollEnabled,
  });

  @override
  State<_LeaderboardListView> createState() => _LeaderboardListViewState();
}

class _LeaderboardListViewState extends State<_LeaderboardListView> {
  final ScrollController _controller = ScrollController();
  bool _highlightMe = false;
  Timer? _highlightTimer;
  late NumberFormat _numberFormat;

  @override
  void initState() {
    super.initState();
    _numberFormat = NumberFormat.decimalPattern(widget.localeName);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (widget.autoScrollEnabled) {
        _scrollToMe();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _LeaderboardListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.localeName != oldWidget.localeName) {
      _numberFormat = NumberFormat.decimalPattern(widget.localeName);
    }
    if (widget.myScore > oldWidget.myScore) {
      _triggerHighlight();
    }

    var shouldScroll = false;
    if (widget.autoScrollEnabled && widget.leaderboard != oldWidget.leaderboard) {
      shouldScroll = true;
    }
    if (widget.autoScrollEnabled &&
        (widget.myScore != oldWidget.myScore || widget.myRank != oldWidget.myRank)) {
      shouldScroll = true;
    }
    if (!oldWidget.autoScrollEnabled && widget.autoScrollEnabled) {
      shouldScroll = true;
    }

    if (shouldScroll && widget.autoScrollEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToMe();
        }
      });
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _triggerHighlight() {
    _highlightTimer?.cancel();
    setState(() {
      _highlightMe = true;
    });
    _highlightTimer = Timer(const Duration(milliseconds: 420), () {
      if (mounted) {
        setState(() {
          _highlightMe = false;
        });
      }
    });
  }

  void _scrollToMe() {
    if (!_controller.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToMe();
        }
      });
      return;
    }
    final opponents = widget.leaderboard.opponents;
    final total = opponents.length + 1;
    if (total <= 0) {
      return;
    }
    final index = (widget.myRank.clamp(1, total)) - 1;
    final desired = index * _rowExtent;
    final position = _controller.position;
    final target = desired
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((position.pixels - target).abs() < 0.5) {
      return;
    }
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _controller.jumpTo(target);
    } else {
      _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  String formatPoints(int value) => _numberFormat.format(value);

  @override
  Widget build(BuildContext context) {
    final opponents = widget.leaderboard.opponents;
    final total = opponents.length + 1;
    final insertionIndex = (widget.myRank.clamp(1, total)) - 1;
    final l10n = AppLocalizations.of(context)!;
    final myScoreText = formatPoints(widget.myScore);

    return CustomScrollView(
      controller: _controller,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          sliver: SliverFixedExtentList(
            itemExtent: _rowExtent,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
        if (index == insertionIndex) {
          final semanticsLabel =
              l10n.yourPosition(index + 1, myScoreText);
          return RepaintBoundary(
            child: _MyLeaderboardRow(
              key: const ValueKey('leaderboard-me'),
              rank: index + 1,
              label: widget.meLabel,
              scoreText: myScoreText,
              highlight: _highlightMe,
              semanticsLabel: semanticsLabel,
            ),
          );
        }

        final opponentIndex = index > insertionIndex ? index - 1 : index;
        final opponent = opponents[opponentIndex];
        final scoreText = formatPoints(opponent.score);
        final semanticsLabel =
            l10n.leaderboardRow(index + 1, opponent.name, scoreText);
        return RepaintBoundary(
          child: _OpponentRow(
            key: ValueKey(opponent.id),
            rank: index + 1,
            name: opponent.name,
            scoreText: scoreText,
            semanticsLabel: semanticsLabel,
          ),
        );
              },
              childCount: total,
            ),
          ),
        ),
      ],
    );
  }
}

class _OpponentRow extends StatelessWidget {
  final int rank;
  final String name;
  final String scoreText;
  final String semanticsLabel;

  const _OpponentRow({
    super.key,
    required this.rank,
    required this.name,
    required this.scoreText,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Semantics(
        label: semanticsLabel,
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _LeaderboardRowContent(
                rank: rank,
                name: name,
                scoreText: scoreText,
                emphasize: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyLeaderboardRow extends StatelessWidget {
  final int rank;
  final String label;
  final String scoreText;
  final bool highlight;
  final String semanticsLabel;

  const _MyLeaderboardRow({
    super.key,
    required this.rank,
    required this.label,
    required this.scoreText,
    required this.highlight,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final baseColor = Color.alphaBlend(cs.primary.withOpacity(0.08), cs.surface);
    final highlightColor =
        Color.alphaBlend(cs.primary.withOpacity(0.18), cs.surface);

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final duration = reduceMotion ? Duration.zero : const Duration(milliseconds: 320);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Semantics(
        label: semanticsLabel,
        selected: true,
        child: SizedBox.expand(
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: highlight ? highlightColor : baseColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: highlight ? cs.primary : cs.primary.withOpacity(0.5),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _LeaderboardRowContent(
              rank: rank,
              name: label,
              scoreText: scoreText,
              emphasize: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardRowContent extends StatelessWidget {
  final int rank;
  final String name;
  final String scoreText;
  final bool emphasize;

  const _LeaderboardRowContent({
    required this.rank,
    required this.name,
    required this.scoreText,
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
          scoreText,
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
