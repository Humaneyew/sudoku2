import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import 'championship_backup.dart';

enum ChampionshipRoundStatus { notStarted, inProgress, completed }

class Opponent {
  final String id;
  final String name;
  final int score;

  const Opponent({required this.id, required this.name, required this.score});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'score': score,
      };

  factory Opponent.fromJson(Map<String, dynamic> json) => Opponent(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        score: (json['score'] as num?)?.toInt() ?? 0,
      );
}

class Leaderboard {
  final List<Opponent> opponents;
  final DateTime generatedAt;

  Leaderboard({
    required List<Opponent> opponents,
    required DateTime generatedAt,
  })  : opponents = List<Opponent>.unmodifiable(opponents),
        generatedAt = generatedAt.toUtc();

  Map<String, dynamic> toJson() => {
        'generatedAt': generatedAt.toIso8601String(),
        'opponents': opponents.map((o) => o.toJson()).toList(),
      };
}

class ChampionshipRound {
  final Difficulty difficulty;
  ChampionshipRoundStatus status;
  DateTime? startedAt;
  DateTime? finishedAt;

  ChampionshipRound({
    required this.difficulty,
    this.status = ChampionshipRoundStatus.notStarted,
    this.startedAt,
    this.finishedAt,
  });

  Map<String, dynamic> toMap() => {
        'difficulty': difficulty.name,
        'status': status.name,
        'startedAt': startedAt?.toUtc().toIso8601String(),
        'finishedAt': finishedAt?.toUtc().toIso8601String(),
      };

  factory ChampionshipRound.fromMap(Map<String, dynamic> map) {
    final difficulty = _parseDifficulty(map['difficulty'] as String?);
    final status = _parseStatus(map['status'] as String?);
    return ChampionshipRound(
      difficulty: difficulty,
      status: status,
      startedAt: _parseDateTime(map['startedAt']),
      finishedAt: _parseDateTime(map['finishedAt']),
    );
  }

  static Difficulty _parseDifficulty(String? value) {
    if (value == null) {
      return Difficulty.novice;
    }
    return Difficulty.values.firstWhere(
      (element) => element.name == value,
      orElse: () => Difficulty.novice,
    );
  }

  static ChampionshipRoundStatus _parseStatus(String? value) {
    if (value == null) {
      return ChampionshipRoundStatus.notStarted;
    }
    return ChampionshipRoundStatus.values.firstWhere(
      (element) => element.name == value,
      orElse: () => ChampionshipRoundStatus.notStarted,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}

class ChampionshipState {
  String sessionId;
  final List<ChampionshipRound> rounds;

  ChampionshipState({
    required this.sessionId,
    required List<ChampionshipRound> rounds,
  }) : rounds = List<ChampionshipRound>.from(rounds);

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'rounds': rounds.map((round) => round.toMap()).toList(),
      };

  factory ChampionshipState.fromMap(Map<String, dynamic> map) {
    final storedRounds = map['rounds'];
    final rounds = _createDefaultRounds();
    if (storedRounds is List) {
      final loadedByDifficulty = <Difficulty, ChampionshipRound>{};
      for (final entry in storedRounds) {
        if (entry is Map<String, dynamic>) {
          final round = ChampionshipRound.fromMap(entry);
          loadedByDifficulty[round.difficulty] = round;
        } else if (entry is Map) {
          final round = ChampionshipRound.fromMap(
            Map<String, dynamic>.from(entry as Map),
          );
          loadedByDifficulty[round.difficulty] = round;
        }
      }
      for (final round in rounds) {
        final loaded = loadedByDifficulty[round.difficulty];
        if (loaded != null) {
          round
            ..status = loaded.status
            ..startedAt = loaded.startedAt
            ..finishedAt = loaded.finishedAt;
        }
      }
    }

    return ChampionshipState(
      sessionId: map['sessionId'] as String? ?? _newSessionId(),
      rounds: rounds,
    );
  }
}

class NextProgressSnapshot {
  const NextProgressSnapshot({
    required this.isTop,
    required this.deltaToNext,
    required this.progress,
    required this.rank,
  });

  final bool isTop;
  final int deltaToNext;
  final double progress;
  final int rank;
}

class ChampionshipModel extends ChangeNotifier {
  ChampionshipModel()
      : _state = ChampionshipState(
          sessionId: _newSessionId(),
          rounds: _createDefaultRounds(),
        );

  static const _prefsKey = 'championship.session.v1';
  static const _myScoreKey = 'champ.perma.myScore.v1';
  static const _installSeedKey = 'champ.perma.installSeed.v1';
  static const _opponentsKey = 'champ.perma.opponents.v1';
  static const _autoScrollKey = 'champ.settings.autoScroll.v1';
  static const _lastAwardedGameIdKey = 'champ.perma.lastAwardedGameId.v1';
  static const _bestScoreKey = 'champ.perma.bestScore.v1';
  static const _bestRankKey = 'champ.perma.bestRank.v1';
  static const int _opponentsCount = 100;
  static const int _maxMyScore = 2000000000;

  static const Map<Difficulty, int> _baseScoreByDifficulty = {
    Difficulty.novice: 60,
    Difficulty.medium: 140,
    Difficulty.high: 260,
    Difficulty.expert: 420,
    Difficulty.master: 600,
  };
  static const List<String> _fallbackNames = [
    'Alex',
    'Sam',
    'Lee',
    'Max',
    'Mia',
    'Noah',
  ];
  static List<String>? _cachedNames;

  ChampionshipState _state;
  int _myScore = 0;
  int _bestScore = 0;
  int _bestRank = 1;
  bool _autoScrollEnabled = true;
  String? _lastAwardedGameId;
  int? _installSeed;
  Leaderboard _leaderboard = Leaderboard(
    opponents: const <Opponent>[],
    generatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );

  String get sessionId => _state.sessionId;

  List<ChampionshipRound> get rounds =>
      List<ChampionshipRound>.unmodifiable(_state.rounds);

  int get myScore => _myScore;

  int get bestScore => _bestScore;

  int get bestRank => _bestRank;

  Leaderboard get leaderboard => _leaderboard;

  bool get autoScrollEnabled => _autoScrollEnabled;

  int get myRank {
    final opponents = _leaderboard.opponents;
    if (opponents.isEmpty) {
      return 1;
    }
    final index = _insertionIndex(opponents, _myScore);
    return index + 1;
  }

  NextProgressSnapshot nextProgress() {
    final opponents = _leaderboard.opponents;
    final currentScore = _myScore;
    final rank = myRank;
    if (rank <= 1 || opponents.isEmpty) {
      return const NextProgressSnapshot(
        isTop: true,
        deltaToNext: 0,
        progress: 1.0,
        rank: 1,
      );
    }

    final insertionIndex = (rank - 1).clamp(0, opponents.length);
    final targetIndex = (insertionIndex - 1).clamp(0, opponents.length - 1);
    final target = opponents[targetIndex];
    final targetScore = target.score;
    final delta = math.max(targetScore - currentScore, 0);

    int lowerScore;
    if (targetIndex + 1 < opponents.length) {
      lowerScore = opponents[targetIndex + 1].score;
    } else {
      lowerScore = currentScore;
    }
    var prevTargetFloor = (targetScore + lowerScore) / 2.0;
    if (prevTargetFloor >= targetScore) {
      prevTargetFloor = targetScore - 1;
    }
    final denominator = targetScore - prevTargetFloor;
    double progress;
    if (denominator <= 0) {
      progress = currentScore >= targetScore ? 1.0 : 0.0;
    } else {
      progress = (currentScore - prevTargetFloor) / denominator;
    }

    return NextProgressSnapshot(
      isTop: false,
      deltaToNext: delta,
      progress: progress.clamp(0.0, 1.0),
      rank: rank,
    );
  }

  int _insertionIndex(List<Opponent> opponents, int score) {
    var low = 0;
    var high = opponents.length;
    while (low < high) {
      final mid = low + ((high - low) >> 1);
      if (score >= opponents[mid].score) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }
    return low;
  }

  int _clampScore(int value) {
    if (value < 0) {
      return 0;
    }
    if (value > _maxMyScore) {
      return _maxMyScore;
    }
    return value;
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) {
      await prefs.setString(_prefsKey, jsonEncode(_state.toMap()));
      return;
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        _state = ChampionshipState.fromMap(decoded);
      } else if (decoded is Map) {
        _state = ChampionshipState.fromMap(
          Map<String, dynamic>.from(decoded as Map),
        );
      } else {
        _state = ChampionshipState(
          sessionId: _newSessionId(),
          rounds: _createDefaultRounds(),
        );
        unawaited(saveToPrefs());
      }
      notifyListeners();
    } on FormatException catch (error) {
      debugPrint('Failed to parse championship session: $error');
      _state = ChampionshipState(
        sessionId: _newSessionId(),
        rounds: _createDefaultRounds(),
      );
      unawaited(saveToPrefs());
      notifyListeners();
    } catch (error) {
      debugPrint('Unexpected error loading championship session: $error');
      _state = ChampionshipState(
        sessionId: _newSessionId(),
        rounds: _createDefaultRounds(),
      );
      unawaited(saveToPrefs());
      notifyListeners();
    }
  }

  Future<void> loadPermaLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    _myScore = _clampScore(prefs.getInt(_myScoreKey) ?? 0);
    _bestScore = _clampScore(prefs.getInt(_bestScoreKey) ?? _myScore);
    _bestRank = prefs.getInt(_bestRankKey) ?? 1;
    _autoScrollEnabled = prefs.getBool(_autoScrollKey) ?? true;
    _lastAwardedGameId = prefs.getString(_lastAwardedGameIdKey);
    _installSeed = prefs.getInt(_installSeedKey);

    Leaderboard? board;
    final stored = prefs.getString(_opponentsKey);
    if (stored != null) {
      try {
        board = _decodeLeaderboard(stored);
      } on FormatException catch (error) {
        debugPrint('Failed to parse stored leaderboard: $error');
        _myScore = 0;
        _bestScore = 0;
        _bestRank = 1;
        await prefs.setInt(_myScoreKey, _myScore);
        await prefs.remove(_opponentsKey);
        await prefs.remove(_lastAwardedGameIdKey);
        await prefs.remove(_bestScoreKey);
        await prefs.remove(_bestRankKey);
        _lastAwardedGameId = null;
        board = null;
      }
    }
    board ??= await _generateLeaderboard(prefs);

    _leaderboard = board;
    if (_bestRank <= 0) {
      _bestRank = myRank;
    }
    if (_bestScore < _myScore) {
      _bestScore = _myScore;
    }
    await prefs.setInt(_bestScoreKey, _bestScore);
    await prefs.setInt(_bestRankKey, _bestRank);
    notifyListeners();
  }

  Future<void> saveMyScore({String? lastGameId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_myScoreKey, _myScore);
    await prefs.setInt(_bestScoreKey, _bestScore);
    await prefs.setInt(_bestRankKey, _bestRank);
    if (lastGameId != null && lastGameId.isNotEmpty) {
      await prefs.setString(_lastAwardedGameIdKey, lastGameId);
    }
  }

  Future<void> resetMyScore() async {
    if (_myScore == 0) {
      return;
    }
    _myScore = 0;
    notifyListeners();
    await saveMyScore();
  }

  Future<void> regenerateOpponents() async {
    final prefs = await SharedPreferences.getInstance();
    final seed = _generateRandomSeed();
    _installSeed = seed;
    await prefs.setInt(_installSeedKey, seed);
    final board = await _generateLeaderboardWithSeed(seed, prefs);
    _leaderboard = board;
    notifyListeners();
  }

  ChampionshipBackupData createBackupData(DateTime exportedAt) {
    final normalizedExportedAt = exportedAt.toUtc();
    final opponents = List<Map<String, dynamic>>.unmodifiable(
      _leaderboard.opponents.map((opponent) => opponent.toJson()),
    );
    final seed = _installSeed ?? 0;
    final lastGameId =
        _lastAwardedGameId != null && _lastAwardedGameId!.isNotEmpty
            ? _lastAwardedGameId
            : null;
    return ChampionshipBackupData(
      version: ChampionshipBackupData.currentVersion,
      exportedAt: normalizedExportedAt,
      myScore: _myScore,
      bestRank: _bestRank,
      bestScore: _bestScore,
      installSeed: seed,
      lastAwardedGameId: lastGameId,
      autoScroll: _autoScrollEnabled,
      opponents: opponents,
    );
  }

  Future<void> restoreFromBackup(ChampionshipBackupData data) async {
    if (data.version != ChampionshipBackupData.currentVersion) {
      throw FormatException('Unsupported backup version: ${data.version}');
    }
    final prefs = await SharedPreferences.getInstance();
    final parsedOpponents = <Opponent>[];
    for (final opponent in data.opponents) {
      parsedOpponents.add(Opponent.fromJson(opponent));
    }
    parsedOpponents.sort((a, b) => b.score.compareTo(a.score));

    var newSeed = data.installSeed;
    if (newSeed <= 0) {
      newSeed = _generateRandomSeed();
    }
    _installSeed = newSeed;
    await prefs.setInt(_installSeedKey, newSeed);

    if (parsedOpponents.isEmpty) {
      _leaderboard = await _generateLeaderboardWithSeed(newSeed, prefs);
    } else {
      _leaderboard = Leaderboard(
        opponents: parsedOpponents,
        generatedAt: data.exportedAt.toUtc(),
      );
      await prefs.setString(_opponentsKey, jsonEncode(_leaderboard.toJson()));
    }

    _myScore = _clampScore(data.myScore);
    _bestScore = _clampScore(data.bestScore);
    _bestRank = data.bestRank > 0 ? data.bestRank : 1;
    _autoScrollEnabled = data.autoScroll;
    final normalizedLastId =
        data.lastAwardedGameId != null && data.lastAwardedGameId!.isNotEmpty
            ? data.lastAwardedGameId
            : null;
    _lastAwardedGameId = normalizedLastId;

    if (_bestScore < _myScore) {
      _bestScore = _myScore;
    }
    if (_bestRank <= 0) {
      _bestRank = myRank;
    }

    await prefs.setInt(_myScoreKey, _myScore);
    await prefs.setInt(_bestScoreKey, _bestScore);
    await prefs.setInt(_bestRankKey, _bestRank);
    await prefs.setBool(_autoScrollKey, _autoScrollEnabled);
    if (normalizedLastId != null) {
      await prefs.setString(_lastAwardedGameIdKey, normalizedLastId);
    } else {
      await prefs.remove(_lastAwardedGameIdKey);
    }

    notifyListeners();
  }

  Future<int> awardScoreForGame({
    required Difficulty difficulty,
    required int timeMs,
    required int mistakes,
    required int hints,
    required String gameId,
    bool isDailyChallenge = false,
  }) async {
    if (_lastAwardedGameId != null && _lastAwardedGameId == gameId) {
      return 0;
    }
    final base = _baseScoreByDifficulty[difficulty] ?? 60;
    final normalizedTime = timeMs <= 0 ? 1 : timeMs;
    final normalizedMistakes = math.max(0, mistakes);
    final normalizedHints = math.max(0, hints);
    final timePenalty = (normalizedTime ~/ 30000) * 5;
    final mistakesPenalty = normalizedMistakes * 20;
    final hintsPenalty = normalizedHints * 30;
    final flawlessBonus =
        (normalizedMistakes == 0 && normalizedHints == 0) ? 50 : 0;
    final dailyBonus = isDailyChallenge ? 30 : 0;

    var delta =
        base + flawlessBonus + dailyBonus - timePenalty - mistakesPenalty - hintsPenalty;
    if (delta < 10) {
      delta = 10;
    } else if (delta > 800) {
      delta = 800;
    }

    final previousScore = _myScore;
    final tentativeScore = previousScore + delta;
    _myScore = _clampScore(tentativeScore);
    final appliedDelta = _myScore - previousScore;
    _lastAwardedGameId = gameId;
    if (_myScore > _bestScore) {
      _bestScore = _myScore;
    }
    final currentRank = myRank;
    if (currentRank < _bestRank) {
      _bestRank = currentRank;
    }
    await saveMyScore(lastGameId: gameId);
    notifyListeners();
    return appliedDelta;
  }

  Future<void> setAutoScrollEnabled(bool value) async {
    if (_autoScrollEnabled == value) {
      return;
    }
    _autoScrollEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoScrollKey, value);
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_state.toMap()));
  }

  void startRound(Difficulty difficulty) {
    final round = _state.rounds.firstWhere(
      (r) => r.difficulty == difficulty,
      orElse: () =>
          throw ArgumentError('Unknown championship difficulty: $difficulty'),
    );

    if (round.status == ChampionshipRoundStatus.completed) {
      return;
    }

    var changed = false;
    if (round.status != ChampionshipRoundStatus.inProgress) {
      round.status = ChampionshipRoundStatus.inProgress;
      round.startedAt ??= DateTime.now().toUtc();
      changed = true;
    } else if (round.startedAt == null) {
      round.startedAt = DateTime.now().toUtc();
      changed = true;
    }

    if (changed) {
      notifyListeners();
      unawaited(saveToPrefs());
    }
  }

  void completeCurrentRound() {
    for (final round in _state.rounds.reversed) {
      if (round.status == ChampionshipRoundStatus.inProgress) {
        round
          ..status = ChampionshipRoundStatus.completed
          ..finishedAt = DateTime.now().toUtc();
        notifyListeners();
        unawaited(saveToPrefs());
        break;
      }
    }
  }

  void resetSession() {
    _state.sessionId = _newSessionId();
    for (final round in _state.rounds) {
      round
        ..status = ChampionshipRoundStatus.notStarted
        ..startedAt = null
        ..finishedAt = null;
    }
    notifyListeners();
    unawaited(saveToPrefs());
  }

  Leaderboard? _decodeLeaderboard(String source) {
    try {
      final decoded = jsonDecode(source);
      final map = decoded is Map<String, dynamic>
          ? decoded
          : decoded is Map
              ? Map<String, dynamic>.from(decoded as Map)
              : null;
      if (map == null) {
        return null;
      }
      final generatedAtString = map['generatedAt'] as String?;
      final generatedAt = generatedAtString != null
          ? DateTime.tryParse(generatedAtString)?.toUtc()
          : null;
      final opponentsValue = map['opponents'];
      if (opponentsValue is! List) {
        return null;
      }
      final opponents = <Opponent>[];
      for (final entry in opponentsValue) {
        if (entry is Map<String, dynamic>) {
          opponents.add(Opponent.fromJson(entry));
        } else if (entry is Map) {
          opponents.add(
            Opponent.fromJson(Map<String, dynamic>.from(entry as Map)),
          );
        }
      }
      if (opponents.isEmpty) {
        return null;
      }
      opponents.sort((a, b) => b.score.compareTo(a.score));
      return Leaderboard(
        opponents: opponents,
        generatedAt: generatedAt ?? DateTime.now().toUtc(),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  Future<Leaderboard> _generateLeaderboard(SharedPreferences prefs) async {
    final seed = await _ensureInstallSeed(prefs);
    return _generateLeaderboardWithSeed(seed, prefs);
  }

  Future<Leaderboard> _generateLeaderboardWithSeed(
    int seed,
    SharedPreferences prefs,
  ) async {
    _installSeed = seed;
    final rng = math.Random(seed);
    final names = await _loadNames();
    final pool = names.isEmpty
        ? List<String>.from(_fallbackNames)
        : List<String>.from(names);
    if (pool.isEmpty) {
      pool.addAll(_fallbackNames);
    }
    pool.shuffle(rng);

    final usage = <String, int>{};
    final generatedNames = <String>[];
    for (var i = 0; i < _opponentsCount; i++) {
      final base = pool[i % pool.length];
      final count = (usage[base] ?? 0) + 1;
      usage[base] = count;
      generatedNames.add(count == 1 ? base : '$base #$count');
    }

    final scores = List<int>.generate(_opponentsCount, (_) => _generateScore(rng))
      ..sort((a, b) => b.compareTo(a));

    final opponents = <Opponent>[
      for (var i = 0; i < _opponentsCount; i++)
        Opponent(
          id: 'o${i + 1}',
          name: generatedNames[i],
          score: scores[i],
        ),
    ];

    final board = Leaderboard(
      opponents: opponents,
      generatedAt: DateTime.now().toUtc(),
    );
    await prefs.setString(_opponentsKey, jsonEncode(board.toJson()));
    return board;
  }

  Future<int> _ensureInstallSeed(SharedPreferences prefs) async {
    final stored = prefs.getInt(_installSeedKey);
    if (stored != null) {
      _installSeed = stored;
      return stored;
    }
    final seed = _generateRandomSeed();
    _installSeed = seed;
    await prefs.setInt(_installSeedKey, seed);
    return seed;
  }

  int _generateRandomSeed() {
    final random = math.Random();
    return (random.nextInt(1 << 16) << 16) | random.nextInt(1 << 16);
  }

  Future<List<String>> _loadNames() async {
    final cached = _cachedNames;
    if (cached != null && cached.isNotEmpty) {
      return List<String>.from(cached);
    }
    try {
      final raw = await rootBundle.loadString('assets/data/names.json');
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final result = <String>[];
        for (final entry in decoded) {
          if (entry is String) {
            final trimmed = entry.trim();
            if (trimmed.isNotEmpty) {
              result.add(trimmed);
            }
          }
        }
        if (result.isNotEmpty) {
          _cachedNames = List<String>.unmodifiable(result);
          return List<String>.from(result);
        }
      }
    } catch (_) {}
    return List<String>.from(_fallbackNames);
  }

  int _generateScore(math.Random rng) {
    const mean = 6000.0;
    const stdDev = 1800.0;
    var u1 = rng.nextDouble();
    if (u1 <= 0) {
      u1 = 1e-10;
    }
    final u2 = rng.nextDouble();
    final gaussian = math.sqrt(-2.0 * math.log(u1)) * math.cos(2 * math.pi * u2);
    final value = mean + stdDev * gaussian;
    final clamped = value.clamp(1000.0, 15000.0);
    return clamped.round();
  }
}

const List<Difficulty> _defaultDifficultyOrder = [
  Difficulty.novice,
  Difficulty.medium,
  Difficulty.high,
  Difficulty.expert,
  Difficulty.master,
];

List<ChampionshipRound> _createDefaultRounds() => _defaultDifficultyOrder
    .map((difficulty) => ChampionshipRound(difficulty: difficulty))
    .toList(growable: false);

String _newSessionId() => DateTime.now().toUtc().toIso8601String();
