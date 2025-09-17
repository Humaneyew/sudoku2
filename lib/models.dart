import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'puzzles.dart';

/// Уровни сложности, используемые в приложении.
enum Difficulty { novice, medium, high, expert, master }

extension DifficultyX on Difficulty {
  /// Человекочитаемое название уровня сложности.
  String title(AppLocalizations l10n) => switch (this) {
        Difficulty.novice => l10n.difficultyNovice,
        Difficulty.medium => l10n.difficultyMedium,
        Difficulty.high => l10n.difficultyHigh,
        Difficulty.expert => l10n.difficultyExpert,
        Difficulty.master => l10n.difficultyMaster,
      };

  /// Короткая подпись, которая хорошо подходит для бейджей и карточек.
  String shortLabel(AppLocalizations l10n) => switch (this) {
        Difficulty.novice => l10n.difficultyNoviceShort,
        Difficulty.medium => l10n.difficultyMediumShort,
        Difficulty.high => l10n.difficultyHighShort,
        Difficulty.expert => l10n.difficultyExpertShort,
        Difficulty.master => l10n.difficultyMasterShort,
      };
}

/// Темы приложения.
enum AppTheme { system, light, dark }

/// Поддерживаемые языки интерфейса.
enum AppLanguage { en, ru, uk, de, fr, zh, hi }

/// Доступные стили отображения цифр на игровом поле.
enum DigitStyle { thin, medium, bold }

extension AppLanguageX on AppLanguage {
  /// Локаль, соответствующая языку приложения.
  Locale get locale => switch (this) {
        AppLanguage.en => const Locale('en'),
        AppLanguage.ru => const Locale('ru'),
        AppLanguage.uk => const Locale('uk'),
        AppLanguage.de => const Locale('de'),
        AppLanguage.fr => const Locale('fr'),
        AppLanguage.zh => const Locale('zh'),
        AppLanguage.hi => const Locale('hi'),
      };

  /// Строковое представление локали (подходит для форматирования дат).
  String get localeCode => locale.languageCode;

  /// Название языка для отображения в настройках.
  String displayName(AppLocalizations l10n) => switch (this) {
        AppLanguage.en => l10n.languageEnglish,
        AppLanguage.ru => l10n.languageRussian,
        AppLanguage.uk => l10n.languageUkrainian,
        AppLanguage.de => l10n.languageGerman,
        AppLanguage.fr => l10n.languageFrench,
        AppLanguage.zh => l10n.languageChinese,
        AppLanguage.hi => l10n.languageHindi,
      };
}

extension DigitStyleX on DigitStyle {
  /// Размер шрифта для выбранного стиля цифр.
  double get fontSize => switch (this) {
        DigitStyle.thin => 18,
        DigitStyle.medium => 20,
        DigitStyle.bold => 22,
      };

  /// Насыщенность шрифта для выбранного стиля цифр.
  FontWeight get fontWeight => switch (this) {
        DigitStyle.thin => FontWeight.w400,
        DigitStyle.medium => FontWeight.w500,
        DigitStyle.bold => FontWeight.w700,
      };

  /// Отображаемое название для настроек.
  String displayName(AppLocalizations l10n) => switch (this) {
        DigitStyle.thin => l10n.digitStyleThin,
        DigitStyle.medium => l10n.digitStyleMedium,
        DigitStyle.bold => l10n.digitStyleBold,
      };
}

/// Состояние активной игры.
class GameState {
  final List<int> board;
  final List<int> solution;
  final List<bool> given;
  final List<Set<int>> notes;

  GameState({
    required this.board,
    required this.solution,
    required this.given,
    required this.notes,
  });
}

/// Хранит статистику для конкретного уровня сложности.
class DifficultyStats {
  int gamesStarted;
  int gamesWon;
  int flawlessWins;
  int bestTimeMs;
  int totalTimeMs;
  int winsWithTime;
  int currentStreak;
  int bestStreak;
  int level;
  int rank;
  int progressCurrent;
  int progressTarget;
  double? overrideWinRate;

  DifficultyStats({
    this.gamesStarted = 0,
    this.gamesWon = 0,
    this.flawlessWins = 0,
    this.bestTimeMs = 0,
    this.totalTimeMs = 0,
    this.winsWithTime = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.level = 1,
    this.rank = 1,
    this.progressCurrent = 0,
    this.progressTarget = 5,
    this.overrideWinRate,
  });

  double get winRate => overrideWinRate ??
      (gamesStarted == 0 ? 0 : gamesWon / gamesStarted);

  String get winRateText => '${(winRate * 100).round()}%';

  String get bestTimeText => bestTimeMs == 0 ? '--:--' : _formatTime(bestTimeMs);

  String get averageTimeText => winsWithTime == 0
      ? '--:--'
      : _formatTime(totalTimeMs ~/ math.max(1, winsWithTime));

  String get progressText => '$progressCurrent / $progressTarget';

  Map<String, dynamic> toJson() => {
        'gamesStarted': gamesStarted,
        'gamesWon': gamesWon,
        'flawlessWins': flawlessWins,
        'bestTimeMs': bestTimeMs,
        'totalTimeMs': totalTimeMs,
        'winsWithTime': winsWithTime,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'level': level,
        'rank': rank,
        'progressCurrent': progressCurrent,
        'progressTarget': progressTarget,
        'overrideWinRate': overrideWinRate,
      };

  factory DifficultyStats.fromJson(Map<String, dynamic> json) => DifficultyStats(
        gamesStarted: json['gamesStarted'] ?? 0,
        gamesWon: json['gamesWon'] ?? 0,
        flawlessWins: json['flawlessWins'] ?? 0,
        bestTimeMs: json['bestTimeMs'] ?? 0,
        totalTimeMs: json['totalTimeMs'] ?? 0,
        winsWithTime: json['winsWithTime'] ?? 0,
        currentStreak: json['currentStreak'] ?? 0,
        bestStreak: json['bestStreak'] ?? 0,
        level: json['level'] ?? 1,
        rank: json['rank'] ?? 1,
        progressCurrent: json['progressCurrent'] ?? 0,
        progressTarget: json['progressTarget'] ?? 5,
        overrideWinRate: (json['overrideWinRate'] as num?)?.toDouble(),
      );

  static String _formatTime(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}

/// Глобальное состояние приложения.
class AppState extends ChangeNotifier {
  static const int _maxHints = 3;
  static const int _maxLives = 3;

  AppTheme theme = AppTheme.system;
  AppLanguage lang = AppLanguage.uk;

  Map<Difficulty, DifficultyStats> statsByDifficulty = _defaultStats();

  final math.Random _random = math.Random();
  final Map<Difficulty, List<int>> _puzzleQueues = {};

  GameState? current;
  Difficulty? currentDifficulty;
  Difficulty featuredDifficulty = Difficulty.novice;

  int totalStars = 0;
  int battleWinRate = 87;
  int championshipScore = 4473;
  int dailyStreak = 0;
  int heartBonus = 1;

  int currentScore = 0;
  int? selectedCell;
  bool notesMode = false;
  int hintsLeft = _maxHints;
  int livesLeft = _maxLives;
  bool soundsEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;
  bool hideCompletedNumbers = false;
  int? highlightedNumber;
  DigitStyle digitStyle = DigitStyle.medium;

  bool _madeMistake = false;
  bool _gameCompleted = false;
  int _sessionId = 0;
  DateTime? _startedAt;

  final List<_Move> _history = [];

  /// Загружаем сохранённые настройки и прогресс.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final profileJson = prefs.getString('profile');
    if (profileJson != null) {
      try {
        final map = jsonDecode(profileJson) as Map<String, dynamic>;
        dailyStreak = map['dailyStreak'] ?? dailyStreak;
        totalStars = map['totalStars'] ?? totalStars;
        championshipScore = map['championshipScore'] ?? championshipScore;
        battleWinRate = map['battleWinRate'] ?? battleWinRate;
        heartBonus = map['heartBonus'] ?? heartBonus;

        final statsMap = map['stats'] as Map<String, dynamic>?;
        if (statsMap != null) {
          final parsed = <Difficulty, DifficultyStats>{};
          for (final entry in statsMap.entries) {
            final key = Difficulty.values.firstWhere(
              (d) => d.name == entry.key,
              orElse: () => Difficulty.novice,
            );
            parsed[key] = DifficultyStats.fromJson(
                (entry.value as Map).cast<String, dynamic>());
          }
          statsByDifficulty = {
            for (final diff in Difficulty.values)
              diff: parsed[diff] ?? _defaultStats()[diff]!,
          };
        }
      } catch (_) {}
    }

    final themeName = prefs.getString('theme');
    if (themeName != null) {
      try {
        theme = AppTheme.values.byName(themeName);
      } catch (_) {}
    }

    final langName = prefs.getString('lang');
    if (langName != null) {
      try {
        lang = AppLanguage.values.byName(langName);
      } catch (_) {}
    }

    final digitStyleName = prefs.getString('digitStyle');
    if (digitStyleName != null) {
      try {
        digitStyle = DigitStyle.values.byName(digitStyleName);
      } catch (_) {}
    }

    soundsEnabled = prefs.getBool('soundsEnabled') ?? soundsEnabled;
    musicEnabled = prefs.getBool('musicEnabled') ?? musicEnabled;
    vibrationEnabled = prefs.getBool('vibrationEnabled') ?? vibrationEnabled;
    hideCompletedNumbers =
        prefs.getBool('hideCompletedNumbers') ?? hideCompletedNumbers;

    final savedGame = prefs.getString('currentGame');
    if (savedGame != null) {
      try {
        final map = jsonDecode(savedGame) as Map<String, dynamic>;
        final diffName = map['difficulty'] as String?;
        final diff = diffName == null
            ? null
            : Difficulty.values.firstWhere(
                (d) => d.name == diffName,
                orElse: () => Difficulty.novice,
              );
        final board = (map['board'] as List?)?.map((e) => e as int).toList();
        final solution =
            (map['solution'] as List?)?.map((e) => e as int).toList();
        final givenList =
            (map['given'] as List?)?.map((e) => e as bool).toList();
        final notesJson = map['notes'] as List?;
        final historyJson = map['history'] as List?;
        final startedAt = map['startedAt'] as String?;

        if (diff != null &&
            board != null &&
            solution != null &&
            givenList != null &&
            board.length == 81 &&
            solution.length == 81 &&
            givenList.length == 81) {
          final notes = List<Set<int>>.generate(81, (index) {
            if (notesJson != null && index < notesJson.length) {
              final entry = notesJson[index];
              if (entry is List) {
                return entry.map((e) => e as int).toSet();
              }
            }
            return <int>{};
          });

          current = GameState(
            board: board,
            solution: solution,
            given: givenList,
            notes: notes,
          );

          currentDifficulty = diff;
          featuredDifficulty = diff;
          _sessionId = (map['sessionId'] as num?)?.toInt() ?? _sessionId;
          currentScore = (map['currentScore'] as num?)?.toInt() ?? currentScore;
          selectedCell = (map['selectedCell'] as num?)?.toInt();
          notesMode = map['notesMode'] as bool? ?? notesMode;
          hintsLeft = (map['hintsLeft'] as num?)?.toInt() ?? hintsLeft;
          livesLeft = (map['livesLeft'] as num?)?.toInt() ?? livesLeft;
          _madeMistake = map['madeMistake'] as bool? ?? _madeMistake;
          _gameCompleted = false;
          _startedAt = startedAt == null ? _startedAt : DateTime.tryParse(startedAt);

          _history
            ..clear()
            ..addAll(
              historyJson
                      ?.whereType<Map>()
                      .map((e) => _Move.fromJson(e.cast<String, dynamic>())) ??
                  const Iterable<_Move>.empty(),
            );
        }
      } catch (_) {}
    }

    notifyListeners();
  }

  /// Сохраняем статистику и прочие данные.
  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = {
      for (final entry in statsByDifficulty.entries)
        entry.key.name: entry.value.toJson(),
    };
    final profile = jsonEncode({
      'dailyStreak': dailyStreak,
      'totalStars': totalStars,
      'championshipScore': championshipScore,
      'battleWinRate': battleWinRate,
      'heartBonus': heartBonus,
      'stats': statsJson,
    });
    await prefs.setString('profile', profile);
  }

  /// Полный сброс статистики к значениям по умолчанию.
  void resetStats() {
    statsByDifficulty = _defaultStats();
    dailyStreak = 0;
    totalStars = 0;
    championshipScore = 4473;
    battleWinRate = 87;
    heartBonus = 1;
    saveProfile();
    notifyListeners();
  }

  void setTheme(AppTheme value) {
    if (theme == value) return;
    theme = value;
    _persist((prefs) async {
      await prefs.setString('theme', value.name);
    });
    notifyListeners();
  }

  void setLang(AppLanguage value) {
    if (lang == value) return;
    lang = value;
    _persist((prefs) async {
      await prefs.setString('lang', value.name);
    });
    notifyListeners();
  }

  void toggleSounds(bool enabled) {
    if (soundsEnabled == enabled) return;
    soundsEnabled = enabled;
    _persist((prefs) async {
      await prefs.setBool('soundsEnabled', enabled);
    });
    notifyListeners();
  }

  void toggleMusic(bool enabled) {
    if (musicEnabled == enabled) return;
    musicEnabled = enabled;
    _persist((prefs) async {
      await prefs.setBool('musicEnabled', enabled);
    });
    notifyListeners();
  }

  void toggleVibration(bool enabled) {
    if (vibrationEnabled == enabled) return;
    vibrationEnabled = enabled;
    _persist((prefs) async {
      await prefs.setBool('vibrationEnabled', enabled);
    });
    notifyListeners();
  }

  void toggleHideCompletedNumbers(bool enabled) {
    if (hideCompletedNumbers == enabled) return;
    hideCompletedNumbers = enabled;
    _persist((prefs) async {
      await prefs.setBool('hideCompletedNumbers', enabled);
    });
    notifyListeners();
  }

  void setDigitStyle(DigitStyle value) {
    if (digitStyle == value) return;
    digitStyle = value;
    _persist((prefs) async {
      await prefs.setString('digitStyle', value.name);
    });
    notifyListeners();
  }

  int _nextPuzzleIndex(Difficulty diff, int length) {
    var queue = _puzzleQueues[diff];
    if (queue == null || queue.isEmpty) {
      queue = List<int>.generate(length, (index) => index);
      queue.shuffle(_random);
      _puzzleQueues[diff] = queue;
    }
    return queue.removeLast();
  }

  /// Запуск новой игры выбранного уровня сложности.
  void startGame(Difficulty diff) {
    final available = puzzles[diff] ?? puzzles[Difficulty.novice];
    if (available == null || available.isEmpty) {
      current = null;
      selectedCell = null;
      notesMode = false;
      hintsLeft = _maxHints;
      livesLeft = _maxLives;
      _history.clear();
      _clearSavedGame();
      notifyListeners();
      return;
    }

    final index = _nextPuzzleIndex(diff, available.length);
    final puzzle = available[index];

    current = GameState(
      board: List.of(puzzle.board),
      solution: List.of(puzzle.solution),
      given: puzzle.board.map((v) => v != 0).toList(),
      notes: List.generate(81, (_) => <int>{}),
    );

    currentDifficulty = diff;
    featuredDifficulty = diff;
    _sessionId++;
    currentScore = 0;
    selectedCell = null;
    notesMode = false;
    hintsLeft = _maxHints;
    livesLeft = _maxLives;
    highlightedNumber = null;
    _madeMistake = false;
    _gameCompleted = false;
    _history.clear();
    _startedAt = DateTime.now();

    statsByDifficulty[diff]?.gamesStarted++;
    _saveCurrentGame();
    saveProfile();
    notifyListeners();
  }

  int get sessionId => _sessionId;

  DateTime? get startedAt => _startedAt;

  bool get hasActiveGame => current != null;

  bool get hasUnfinishedGame => current != null && !_gameCompleted;

  bool get isOutOfLives => livesLeft <= 0;

  bool get isSolved {
    final game = current;
    if (game == null) return false;
    for (var i = 0; i < 81; i++) {
      if (game.board[i] != game.solution[i]) {
        return false;
      }
    }
    return true;
  }

  bool get gameCompleted => _gameCompleted;

  DifficultyStats statsFor(Difficulty diff) =>
      statsByDifficulty[diff] ?? DifficultyStats();

  Difficulty get featuredStatsDifficulty {
    if (currentDifficulty != null) {
      return currentDifficulty!;
    }
    return featuredDifficulty;
  }

  void selectCell(int index) {
    if (current == null) return;
    selectedCell = index;
    notifyListeners();
  }

  void setHighlightedNumber(int? number) {
    if (highlightedNumber == number) return;
    highlightedNumber = number;
    notifyListeners();
  }

  void handleNumberInput(int number) {
    final idx = selectedCell;
    if (current == null || idx == null) return;
    if (notesMode) {
      toggleNoteAt(idx, number);
    } else {
      makeMove(idx, number);
    }
  }

  void makeMove(int index, int value) {
    final game = current;
    if (game == null) return;
    if (game.given[index]) return;
    if (isOutOfLives) return;

    final previousValue = game.board[index];
    final previousNotes = _cloneNotes(index);
    if (previousValue == value) return;

    final correct = isMoveValid(index, value);
    var consumedLife = false;

    if (!correct) {
      livesLeft = math.max(0, livesLeft - 1);
      consumedLife = true;
      _madeMistake = true;
    } else {
      currentScore += 12;
      _handleCorrectFeedback();
    }

    _history.add(_Move(
      index: index,
      previousValue: previousValue,
      previousNotes: previousNotes,
      consumedLife: consumedLife,
    ));

    game.board[index] = value;
    game.notes[index].clear();

    _saveCurrentGame();
    notifyListeners();
  }

  void toggleNoteAt(int index, int value) {
    final game = current;
    if (game == null) return;
    if (game.given[index]) return;

    final previousNotes = _cloneNotes(index);
    final notes = game.notes[index];
    if (notes.contains(value)) {
      notes.remove(value);
    } else {
      notes.add(value);
    }

    _history.add(_Move(
      index: index,
      previousValue: game.board[index],
      previousNotes: previousNotes,
      noteChange: true,
    ));

    _saveCurrentGame();
    notifyListeners();
  }

  void eraseCell() {
    final game = current;
    final idx = selectedCell;
    if (game == null || idx == null) return;
    if (game.given[idx]) return;
    if (game.board[idx] == 0 && game.notes[idx].isEmpty) return;

    final previousValue = game.board[idx];
    final previousNotes = _cloneNotes(idx);

    _history.add(_Move(
      index: idx,
      previousValue: previousValue,
      previousNotes: previousNotes,
    ));

    game.board[idx] = 0;
    game.notes[idx].clear();
    _saveCurrentGame();
    notifyListeners();
  }

  void useHint() {
    final game = current;
    final idx = selectedCell;
    if (game == null || idx == null) return;
    if (game.given[idx]) return;
    if (hintsLeft <= 0) return;

    final previousValue = game.board[idx];
    final previousNotes = _cloneNotes(idx);
    final correct = game.solution[idx];
    if (previousValue == correct) return;

    _history.add(_Move(
      index: idx,
      previousValue: previousValue,
      previousNotes: previousNotes,
      consumedHint: true,
    ));

    game.board[idx] = correct;
    game.notes[idx].clear();
    hintsLeft = math.max(0, hintsLeft - 1);
    currentScore += 8;
    _saveCurrentGame();
    notifyListeners();
  }

  void toggleNotesMode() {
    if (current == null) return;
    notesMode = !notesMode;
    _saveCurrentGame();
    notifyListeners();
  }

  void undoMove() {
    final game = current;
    if (game == null || _history.isEmpty) return;

    final last = _history.removeLast();
    game.board[last.index] = last.previousValue;
    game.notes[last.index]
      ..clear()
      ..addAll(last.previousNotes);

    if (last.consumedHint) {
      hintsLeft = math.min(_maxHints, hintsLeft + 1);
    }

    if (last.consumedLife) {
      livesLeft = math.min(_maxLives, livesLeft + 1);
    }

    selectedCell = last.index;
    _saveCurrentGame();
    notifyListeners();
  }

  void restoreOneLife() {
    livesLeft = math.max(1, livesLeft);
    _saveCurrentGame();
    notifyListeners();
  }

  /// Завершение партии (вызывается, когда все клетки заполнены корректно).
  void completeGame(int elapsedMs) {
    if (current == null) return;
    if (_gameCompleted) return;
    if (!isSolved) return;

    _gameCompleted = true;
    totalStars += 1;
    _handleVictoryFeedback();

    final diff = currentDifficulty;
    if (diff != null) {
      final stats = statsByDifficulty[diff];
      if (stats != null) {
        stats.gamesWon++;
        stats.winsWithTime++;
        stats.totalTimeMs += elapsedMs;
        if (stats.bestTimeMs == 0 || elapsedMs < stats.bestTimeMs) {
          stats.bestTimeMs = elapsedMs;
        }
        if (!_madeMistake) {
          stats.flawlessWins++;
        }
        stats.currentStreak++;
        stats.bestStreak = math.max(stats.bestStreak, stats.currentStreak);
        stats.progressCurrent = math.min(
          stats.progressTarget,
          stats.progressCurrent + 1,
        );
        if (stats.progressCurrent >= stats.progressTarget) {
          stats.level++;
          stats.rank = math.max(1, stats.rank - 1);
          stats.progressCurrent = 0;
          stats.progressTarget += stats.level ~/ 2 + 5;
          heartBonus = 1;
        }
      }
    }

    _clearSavedGame();
    saveProfile();
    notifyListeners();
  }

  void registerFailure() {
    _handleDefeatFeedback();
    final diff = currentDifficulty;
    if (diff != null) {
      final stats = statsByDifficulty[diff];
      if (stats != null) {
        stats.currentStreak = 0;
      }
    }
    _clearSavedGame();
    saveProfile();
    notifyListeners();
  }

  void abandonGame() {
    current = null;
    currentDifficulty = null;
    currentScore = 0;
    selectedCell = null;
    notesMode = false;
    hintsLeft = _maxHints;
    livesLeft = _maxLives;
    _madeMistake = false;
    _gameCompleted = false;
    _history.clear();
    highlightedNumber = null;
    _clearSavedGame();
    notifyListeners();
  }

  /// Подсчёт оставшихся чисел для панели управления.
  int countRemaining(int number) {
    final game = current;
    if (game == null) return 9;
    return 9 - game.board.where((v) => v == number).length;
  }

  bool isNumberCompleted(int number) {
    final game = current;
    if (game == null) return false;
    final occurrences = game.board.where((v) => v == number).length;
    if (occurrences != 9) return false;
    for (var i = 0; i < game.board.length; i++) {
      if (game.solution[i] == number && game.board[i] != number) {
        return false;
      }
    }
    return true;
  }

  bool get canUndoMove => _history.isNotEmpty;

  int? get selectedValue {
    final idx = selectedCell;
    final game = current;
    if (idx == null || game == null) return null;
    final value = game.board[idx];
    return value == 0 ? null : value;
  }

  bool isMoveValid(int index, int value) {
    final game = current;
    if (game == null) return false;
    if (value == 0) return true;
    return game.solution[index] == value;
  }

  bool hasConflict(int index) {
    final game = current;
    if (game == null) return false;
    final value = game.board[index];
    if (value == 0) return false;

    for (final peer in _peersOf(index)) {
      if (peer != index && game.board[peer] == value) {
        return true;
      }
    }
    return !isMoveValid(index, value);
  }

  bool isPeerOfSelected(int index) {
    final selected = selectedCell;
    if (selected == null || selected == index) return false;
    return _peersOf(selected).contains(index);
  }

  bool isSameAsSelectedValue(int index) {
    final selected = selectedCell;
    final game = current;
    if (selected == null || game == null) return false;
    if (game.board[selected] == 0) return false;
    return game.board[index] == game.board[selected];
  }

  bool isHighlightedCandidate(int index) {
    final number = highlightedNumber;
    final game = current;
    if (number == null || game == null) return false;
    if (game.board[index] != 0) return false;
    return game.solution[index] == number;
  }

  List<int> rowIndices(int index) {
    final row = index ~/ 9;
    return List.generate(9, (i) => row * 9 + i);
  }

  List<int> columnIndices(int index) {
    final col = index % 9;
    return List.generate(9, (i) => col + i * 9);
  }

  List<int> boxIndices(int index) {
    final row = index ~/ 9;
    final col = index % 9;
    final startRow = (row ~/ 3) * 3;
    final startCol = (col ~/ 3) * 3;
    final indices = <int>[];
    for (var r = startRow; r < startRow + 3; r++) {
      for (var c = startCol; c < startCol + 3; c++) {
        indices.add(r * 9 + c);
      }
    }
    return indices;
  }

  Set<int> _peersOf(int index) {
    final peers = <int>{}
      ..addAll(rowIndices(index))
      ..addAll(columnIndices(index))
      ..addAll(boxIndices(index));
    peers.remove(index);
    return peers;
  }

  Set<int> _cloneNotes(int index) {
    final game = current;
    if (game == null) return <int>{};
    return {...game.notes[index]};
  }

  void _handleCorrectFeedback() {
    _playSound(SystemSoundType.click);
    _triggerVibration(HapticFeedback.selectionClick);
  }

  void _handleVictoryFeedback() {
    _playSound(SystemSoundType.alert);
    _triggerVibration(HapticFeedback.mediumImpact);
  }

  void _handleDefeatFeedback() {
    _playSound(SystemSoundType.alert);
    _triggerVibration(HapticFeedback.heavyImpact);
  }

  void _playSound(SystemSoundType type) {
    if (!soundsEnabled) return;
    SystemSound.play(type);
  }

  void _triggerVibration(Future<void> Function() callback) {
    if (!vibrationEnabled) return;
    callback();
  }

  void _saveCurrentGame() {
    final game = current;
    final diff = currentDifficulty;
    if (game == null || diff == null || _gameCompleted) {
      _clearSavedGame();
      return;
    }

    final data = {
      'difficulty': diff.name,
      'board': game.board,
      'solution': game.solution,
      'given': game.given,
      'notes': game.notes.map((set) => set.toList()).toList(),
      'currentScore': currentScore,
      'selectedCell': selectedCell,
      'notesMode': notesMode,
      'hintsLeft': hintsLeft,
      'livesLeft': livesLeft,
      'madeMistake': _madeMistake,
      'startedAt': _startedAt?.toIso8601String(),
      'sessionId': _sessionId,
      'history': _history.map((move) => move.toJson()).toList(),
    };

    _persist((prefs) async {
      await prefs.setString('currentGame', jsonEncode(data));
    });
  }

  void _clearSavedGame() {
    _persist((prefs) async {
      await prefs.remove('currentGame');
    });
  }

  void _persist(Future<void> Function(SharedPreferences prefs) save) {
    SharedPreferences.getInstance().then(save);
  }
}

class _Move {
  final int index;
  final int previousValue;
  final Set<int> previousNotes;
  final bool consumedHint;
  final bool consumedLife;
  final bool noteChange;

  _Move({
    required this.index,
    required this.previousValue,
    required this.previousNotes,
    this.consumedHint = false,
    this.consumedLife = false,
    this.noteChange = false,
  });

  Map<String, dynamic> toJson() => {
        'index': index,
        'previousValue': previousValue,
        'previousNotes': previousNotes.toList(),
        'consumedHint': consumedHint,
        'consumedLife': consumedLife,
        'noteChange': noteChange,
      };

  factory _Move.fromJson(Map<String, dynamic> json) => _Move(
        index: (json['index'] as num?)?.toInt() ?? 0,
        previousValue: (json['previousValue'] as num?)?.toInt() ?? 0,
        previousNotes: ((json['previousNotes'] as List?)
                ?.map((e) => (e as num).toInt())
                .toSet()) ??
            <int>{},
        consumedHint: json['consumedHint'] as bool? ?? false,
        consumedLife: json['consumedLife'] as bool? ?? false,
        noteChange: json['noteChange'] as bool? ?? false,
      );
}

Map<Difficulty, DifficultyStats> _defaultStats() => {
      for (final diff in Difficulty.values) diff: DifficultyStats(),
    };
