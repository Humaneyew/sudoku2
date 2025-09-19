import 'package:intl/intl.dart';

import 'models.dart';

class StatsFormatResult {
  final String gamesStarted;
  final String gamesWon;
  final String flawlessWins;
  final String currentStreak;
  final String bestStreak;

  const StatsFormatResult({
    required this.gamesStarted,
    required this.gamesWon,
    required this.flawlessWins,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StatsFormatResult &&
            other.gamesStarted == gamesStarted &&
            other.gamesWon == gamesWon &&
            other.flawlessWins == flawlessWins &&
            other.currentStreak == currentStreak &&
            other.bestStreak == bestStreak;
  }

  @override
  int get hashCode => Object.hash(
        gamesStarted,
        gamesWon,
        flawlessWins,
        currentStreak,
        bestStreak,
      );
}

class StatsFormatter {
  const StatsFormatter._();

  static StatsFormatResult formatNumbers(
    DifficultyStats stats,
    String localeName,
  ) {
    final formatter = NumberFormat.decimalPattern(localeName);
    return StatsFormatResult(
      gamesStarted: formatter.format(stats.gamesStarted),
      gamesWon: formatter.format(stats.gamesWon),
      flawlessWins: formatter.format(stats.flawlessWins),
      currentStreak: formatter.format(stats.currentStreak),
      bestStreak: formatter.format(stats.bestStreak),
    );
  }
}
