import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

enum ChampionshipRoundStatus { notStarted, inProgress, completed }

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

class ChampionshipModel extends ChangeNotifier {
  ChampionshipModel()
      : _state = ChampionshipState(
          sessionId: _newSessionId(),
          rounds: _createDefaultRounds(),
        );

  static const _prefsKey = 'championship.session.v1';

  ChampionshipState _state;

  String get sessionId => _state.sessionId;

  List<ChampionshipRound> get rounds =>
      List<ChampionshipRound>.unmodifiable(_state.rounds);

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
    } catch (_) {
      _state = ChampionshipState(
        sessionId: _newSessionId(),
        rounds: _createDefaultRounds(),
      );
      unawaited(saveToPrefs());
      notifyListeners();
    }
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
