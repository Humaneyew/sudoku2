import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku2/flutter_gen/gen_l10n/app_localizations.dart';

import 'puzzles.dart';
import 'theme.dart';

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

/// Поддерживаемые языки интерфейса.
enum AppLanguage { en, ru, uk, de, fr, es, it, zh, hi, ja, ko, ka }

/// Доступные варианты размера шрифта для интерфейса игры.
enum FontSizeOption { extraSmall, small, medium, large, extraLarge }

extension AppLanguageX on AppLanguage {
  /// Локаль, соответствующая языку приложения.
  Locale get locale => switch (this) {
        AppLanguage.en => const Locale('en'),
        AppLanguage.ru => const Locale('ru'),
        AppLanguage.uk => const Locale('uk'),
        AppLanguage.de => const Locale('de'),
        AppLanguage.fr => const Locale('fr'),
        AppLanguage.es => const Locale('es'),
        AppLanguage.it => const Locale('it'),
        AppLanguage.zh => const Locale('zh'),
        AppLanguage.hi => const Locale('hi'),
        AppLanguage.ja => const Locale('ja'),
        AppLanguage.ko => const Locale('ko'),
        AppLanguage.ka => const Locale('ka'),
      };

  /// Полный тэг локали в формате BCP 47.
  String toLocaleTag() => switch (this) {
        AppLanguage.en => 'en-US',
        AppLanguage.ru => 'ru-RU',
        AppLanguage.uk => 'uk-UA',
        AppLanguage.de => 'de-DE',
        AppLanguage.fr => 'fr-FR',
        AppLanguage.es => 'es-ES',
        AppLanguage.it => 'it-IT',
        AppLanguage.zh => 'zh-CN',
        AppLanguage.hi => 'hi-IN',
        AppLanguage.ja => 'ja-JP',
        AppLanguage.ko => 'ko-KR',
        AppLanguage.ka => 'ka-GE',
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
        AppLanguage.es => l10n.languageSpanish,
        AppLanguage.it => l10n.languageItalian,
        AppLanguage.zh => l10n.languageChinese,
        AppLanguage.hi => l10n.languageHindi,
        AppLanguage.ja => l10n.languageJapanese,
        AppLanguage.ko => l10n.languageKorean,
        AppLanguage.ka => l10n.languageGeorgian,
      };
}

extension FontSizeOptionX on FontSizeOption {
  /// Коэффициент масштабирования текста относительно базового размера.
  double get scale => switch (this) {
        FontSizeOption.extraSmall => 0.85,
        FontSizeOption.small => 0.95,
        FontSizeOption.medium => 1.0,
        FontSizeOption.large => 1.1,
        FontSizeOption.extraLarge => 1.25,
      };

  /// Название варианта размера шрифта для отображения пользователю.
  String label(AppLocalizations l10n) => switch (this) {
        FontSizeOption.extraSmall => l10n.fontSizeExtraSmall,
        FontSizeOption.small => l10n.fontSizeSmall,
        FontSizeOption.medium => l10n.fontSizeMedium,
        FontSizeOption.large => l10n.fontSizeLarge,
        FontSizeOption.extraLarge => l10n.fontSizeExtraLarge,
      };
}

/// Режим активной игры.
enum GameMode { classic, daily, battle }

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

final _elapsedMsExpando = Expando<int>('elapsedMs');

extension GameStateElapsedMs on GameState {
  int get elapsedMs => _elapsedMsExpando[this] ?? 0;

  set elapsedMs(int value) => _elapsedMsExpando[this] = value;
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
  static const int _maxHints = 1;
  static const int _maxLives = 3;
  static const int _novicePuzzleLimit = 50;
  static final Set<String> _initedDateLocales = <String>{};

  SudokuTheme theme = SudokuTheme.white;
  AppLanguage lang = AppLanguage.uk;
  // Перенастраиваем шкалу размеров шрифтов без изменения верстки:
  // Small берёт прежний Medium (17 sp), Medium — прежний Large (19 sp),
  // а Large увеличиваем пропорционально относительно нового Medium.
  static const double _previousMediumFontSizeSp = 17.0;
  static const double _previousLargeFontSizeSp = 19.0;
  static const double minFontSizeSp = _previousMediumFontSizeSp;
  static const double mediumFontSizeSp = _previousLargeFontSizeSp;
  static const double _fontStepMultiplier =
      mediumFontSizeSp / minFontSizeSp;
  static const double maxFontSizeSp =
      mediumFontSizeSp * _fontStepMultiplier;
  static const List<double> fontSizeOptionsSp = [
    minFontSizeSp,
    mediumFontSizeSp,
    maxFontSizeSp,
  ];
  static const double _baseFontSizeSp = 16.0;
  static const double minFontScale = minFontSizeSp / _baseFontSizeSp;
  static const double maxFontScale = maxFontSizeSp / _baseFontSizeSp;
  double _fontScale = 1.0;

  Map<Difficulty, DifficultyStats> statsByDifficulty = _defaultStats();

  final math.Random _random = math.Random();
  final Map<Difficulty, List<int>> _puzzleQueues = {};

  GameState? current;
  Difficulty? currentDifficulty;
  GameMode? currentMode;
  Difficulty featuredDifficulty = Difficulty.novice;

  String? playerFlag;

  int totalStars = 0;
  int battleGamesWon = 0;
  int battleGamesPlayed = 0;
  int championshipScore = 4473;
  int dailyStreak = 0;
  DateTime? _lastVictoryDate;
  int heartBonus = 1;

  int get battleWinRate {
    if (battleGamesPlayed == 0) {
      return 0;
    }
    final rate = ((battleGamesWon / battleGamesPlayed) * 100).round();
    return math.max(0, math.min(100, rate));
  }

  final Set<String> _completedDailyChallenges = <String>{};
  DateTime? _dailyChallengeDate;

  int currentScore = 0;
  int? selectedCell;
  bool notesMode = false;
  int hintsLeft = _maxHints;
  int _hintsConsumed = 0;
  int livesLeft = _maxLives;
  bool soundsEnabled = true;
  bool vibrationEnabled = true;
  int? highlightedNumber;
  bool _madeMistake = false;
  bool _gameCompleted = false;
  int _sessionId = 0;
  DateTime? _startedAt;
  String? _currentGameId;

  final List<_Move> _history = [];
  Timer? _saveDebounce;

  /// Загружаем сохранённые настройки и прогресс.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _dailyChallengeDate = null;
      _currentGameId = null;
      _lastVictoryDate = null;

      final completedDaily = prefs.getStringList('dailyCompleted');
      if (completedDaily != null) {
        _completedDailyChallenges
          ..clear()
          ..addAll(completedDaily);
      }

      final profileJson = prefs.getString('profile');
      if (profileJson != null) {
        try {
          final map = jsonDecode(profileJson) as Map<String, dynamic>;
          dailyStreak = map['dailyStreak'] ?? dailyStreak;
          final lastVictory = map['lastVictoryDate'];
          if (lastVictory is String && lastVictory.isNotEmpty) {
            final parsed = DateTime.tryParse(lastVictory);
            if (parsed != null) {
              _lastVictoryDate = _dateOnly(parsed);
            }
          }
          totalStars = map['totalStars'] ?? totalStars;
          championshipScore = map['championshipScore'] ?? championshipScore;
          battleGamesWon =
              (map['battleGamesWon'] as num?)?.toInt() ?? battleGamesWon;
          battleGamesPlayed =
              (map['battleGamesPlayed'] as num?)?.toInt() ?? battleGamesPlayed;
          if (battleGamesWon < 0) {
            battleGamesWon = 0;
          }
          if (battleGamesPlayed < battleGamesWon) {
            battleGamesPlayed = battleGamesWon;
          }
          if (battleGamesWon == 0 && battleGamesPlayed == 0) {
            final legacyBattleWins = map['battleWinRate'];
            if (legacyBattleWins is num) {
              final wins = legacyBattleWins.toInt();
              if (wins > 87) {
                battleGamesWon = wins - 87;
                battleGamesPlayed = battleGamesWon;
              } else if (wins == 87) {
                battleGamesWon = 0;
                battleGamesPlayed = 0;
              }
            }
          }
          heartBonus = map['heartBonus'] ?? heartBonus;
          playerFlag = (map['playerFlag'] as String?) ?? playerFlag;

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

      final themeName = prefs.getString('themeV2') ?? prefs.getString('theme');
      if (themeName != null) {
        try {
          theme = SudokuTheme.values.byName(themeName);
        } catch (_) {
          switch (themeName) {
            case 'light':
              theme = SudokuTheme.white;
              break;
            case 'dark':
              theme = SudokuTheme.black;
              break;
            case 'system':
              theme = SudokuTheme.white;
              break;
          }
        }
      }

      final storedScale = prefs.getDouble('fontScaleV2');
      var migratedFontScale = false;

      if (storedScale != null) {
        final normalized = _normalizeFontScale(storedScale);
        if ((normalized - storedScale).abs() > 0.0001) {
          migratedFontScale = true;
        }
        _fontScale = normalized;
      } else {
        FontSizeOption? option;
        final storedFontSize = prefs.getString('fontSize');
        if (storedFontSize != null) {
          try {
            option = FontSizeOption.values.byName(storedFontSize);
          } catch (_) {}
        }

        if (option != null) {
          _fontScale = _normalizeFontScale(option.scale);
          migratedFontScale = true;
        } else {
          final legacyScale = prefs.getDouble('fontScale');
          if (legacyScale != null) {
            _fontScale = _normalizeFontScale(legacyScale);
            migratedFontScale = true;
          } else {
            final digitStyleName = prefs.getString('digitStyle');
            if (digitStyleName != null) {
              switch (digitStyleName) {
                case 'thin':
                  option = FontSizeOption.extraSmall;
                  break;
                case 'bold':
                  option = FontSizeOption.extraLarge;
                  break;
                default:
                  option = FontSizeOption.medium;
              }
              if (option != null) {
                _fontScale = _normalizeFontScale(option.scale);
                migratedFontScale = true;
              }
            }
          }
        }
      }

      _fontScale = _normalizeFontScale(_fontScale);

      if (migratedFontScale) {
        await prefs.setDouble('fontScaleV2', _fontScale);
      }

      await prefs.remove('fontSize');
      await prefs.remove('fontScale');
      await prefs.remove('digitStyle');
      await prefs.remove('syncWithSystemTheme');

      final langName = prefs.getString('lang');
      if (langName != null) {
        try {
          lang = AppLanguage.values.byName(langName);
        } catch (_) {}
      }

      soundsEnabled = prefs.getBool('soundsEnabled') ?? soundsEnabled;
      vibrationEnabled = prefs.getBool('vibrationEnabled') ?? vibrationEnabled;
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
          final modeName = map['mode'] as String?;
          GameMode? mode;
          if (modeName != null) {
            try {
              mode = GameMode.values.byName(modeName);
            } catch (_) {}
          }
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
            currentMode = mode ?? GameMode.classic;
            _sessionId = (map['sessionId'] as num?)?.toInt() ?? _sessionId;
            currentScore = (map['currentScore'] as num?)?.toInt() ?? currentScore;
            selectedCell = (map['selectedCell'] as num?)?.toInt();
            notesMode = map['notesMode'] as bool? ?? notesMode;
            hintsLeft = (map['hintsLeft'] as num?)?.toInt() ?? hintsLeft;
            hintsLeft = math.max(0, math.min(_maxHints, hintsLeft));
            _hintsConsumed = (map['hintsConsumed'] as num?)?.toInt() ??
                (_maxHints - hintsLeft);
            _hintsConsumed = math.max(0, _hintsConsumed);
            livesLeft = (map['livesLeft'] as num?)?.toInt() ?? livesLeft;
            _madeMistake = map['madeMistake'] as bool? ?? _madeMistake;
            _gameCompleted = false;
            _startedAt =
                startedAt == null ? _startedAt : DateTime.tryParse(startedAt);
            final dailyDateString = map['dailyDate'] as String?;
            final parsedDailyDate = dailyDateString == null
                ? null
                : DateTime.tryParse(dailyDateString);
            _dailyChallengeDate =
                parsedDailyDate == null ? null : _dateOnly(parsedDailyDate);

            _currentGameId = (map['gameId'] as String?)?.trim();
            if (diff != null && (_currentGameId == null || _currentGameId!.isEmpty)) {
              _currentGameId = _composeGameId(diff);
              scheduleSave();
            }

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
    } catch (e) {
      assert(() {
        debugPrint('AppState.load error: $e');
        return true;
      }());
    }

    _refreshDailyStreak();

    await _ensureDateLocaleInited(lang.toLocaleTag());
    notifyListeners();
  }

  /// Сохраняем статистику и прочие данные.
  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = {
      for (final entry in statsByDifficulty.entries)
        entry.key.name: entry.value.toJson(),
    };
    final lastVictoryDate =
        _lastVictoryDate == null ? null : _dateOnly(_lastVictoryDate!).toIso8601String();
    final profile = jsonEncode({
      'dailyStreak': dailyStreak,
      'lastVictoryDate': lastVictoryDate,
      'totalStars': totalStars,
      'championshipScore': championshipScore,
      'battleGamesWon': battleGamesWon,
      'battleGamesPlayed': battleGamesPlayed,
      'battleWinRate': battleWinRate,
      'heartBonus': heartBonus,
      'playerFlag': playerFlag,
      'stats': statsJson,
    });
    await prefs.setString('profile', profile);
  }

  /// Полный сброс статистики к значениям по умолчанию.
  void resetStats() {
    statsByDifficulty = _defaultStats();
    dailyStreak = 0;
    _lastVictoryDate = null;
    totalStars = 0;
    championshipScore = 4473;
    battleGamesWon = 0;
    battleGamesPlayed = 0;
    heartBonus = 1;
    _completedDailyChallenges.clear();
    _dailyChallengeDate = null;
    _saveDailyProgress();
    saveProfile();
    notifyListeners();
  }

  void setPlayerFlag(String value) {
    if (playerFlag == value) {
      return;
    }
    playerFlag = value;
    unawaited(saveProfile());
    notifyListeners();
  }

  void setTheme(SudokuTheme value) {
    if (theme == value) return;
    theme = value;
    _persist((prefs) async {
      await prefs.setString('themeV2', value.name);
    });
    notifyListeners();
  }

  void setFontScale(double value, {bool save = true}) {
    final normalized = _normalizeFontScale(value);
    if ((_fontScale - normalized).abs() < 0.001) return;
    _fontScale = normalized;
    if (save) {
      _persist((prefs) async {
        await prefs.setDouble('fontScaleV2', _fontScale);
        await prefs.remove('fontSize');
        await prefs.remove('fontScale');
      });
    }
    notifyListeners();
  }

  void setFontSizeSp(double value, {bool save = true}) {
    setFontScale(value / _baseFontSizeSp, save: save);
  }

  void setFontSizeByIndex(double value, {bool save = true}) {
    final maxIndex = fontSizeOptionsSp.length - 1;
    final normalized = value.clamp(0, maxIndex.toDouble());
    final targetIndex = math.max(0, math.min(maxIndex, normalized.round()));
    setFontSizeSp(fontSizeOptionsSp[targetIndex], save: save);
  }

  double get fontScale => _fontScale;

  double get fontSizeSp => _fontScale * _baseFontSizeSp;

  int get fontSizeIndex {
    final current = _nearestFontSize(fontSizeSp);
    final index = fontSizeOptionsSp.indexOf(current);
    return index == -1 ? 0 : index;
  }

  static double _normalizeFontScale(double scale) {
    final clamped = scale.clamp(minFontScale, maxFontScale).toDouble();
    final fontSize = clamped * _baseFontSizeSp;
    final nearest = _nearestFontSize(fontSize);
    return nearest / _baseFontSizeSp;
  }

  static double _nearestFontSize(double value) {
    var nearest = fontSizeOptionsSp.first;
    for (final option in fontSizeOptionsSp.skip(1)) {
      final diff = (option - value).abs();
      final nearestDiff = (nearest - value).abs();
      if (diff < nearestDiff || (diff == nearestDiff && option > nearest)) {
        nearest = option;
      }
    }
    return nearest;
  }

  SudokuTheme resolvedTheme() {
    return theme;
  }

  String resolvedThemeName(AppLocalizations l10n) {
    return resolvedTheme().label(l10n);
  }

  Future<void> _ensureDateLocaleInited(String localeTag) async {
    if (_initedDateLocales.contains(localeTag)) return;
    await initializeDateFormatting(localeTag);
    _initedDateLocales.add(localeTag);
  }

  Future<void> setLang(AppLanguage value) async {
    if (lang == value) return;
    lang = value;
    _persist((prefs) async {
      await prefs.setString('lang', value.name);
    });
    final tag = lang.toLocaleTag();
    await _ensureDateLocaleInited(tag);
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

  void toggleVibration(bool enabled) {
    if (vibrationEnabled == enabled) return;
    vibrationEnabled = enabled;
    _persist((prefs) async {
      await prefs.setBool('vibrationEnabled', enabled);
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

  String _composeGameId(Difficulty diff) {
    final started = _startedAt ?? DateTime.now();
    final timestamp = started.toUtc().microsecondsSinceEpoch;
    return '$timestamp-${diff.name}-$_sessionId';
  }

  void startDailyChallenge(DateTime date) {
    final normalized = _dateOnly(date);
    final puzzle = generateDailyPuzzle(normalized);

    current = GameState(
      board: List.of(puzzle.board),
      solution: List.of(puzzle.solution),
      given: puzzle.board.map((v) => v != 0).toList(),
      notes: List.generate(81, (_) => <int>{}),
    );

    currentDifficulty = Difficulty.medium;
    featuredDifficulty = Difficulty.medium;
    currentMode = GameMode.daily;
    _dailyChallengeDate = normalized;
    _sessionId++;
    currentScore = 0;
    selectedCell = null;
    notesMode = false;
    hintsLeft = _maxHints;
    _hintsConsumed = 0;
    livesLeft = _maxLives;
    highlightedNumber = null;
    _madeMistake = false;
    _gameCompleted = false;
    _history.clear();
    _startedAt = DateTime.now();
    _currentGameId = _composeGameId(Difficulty.medium);

    statsByDifficulty[Difficulty.medium]?.gamesStarted++;
    scheduleSave();
    saveProfile();
    notifyListeners();
  }

  /// Запуск новой игры выбранного уровня сложности.
  void startGame(Difficulty diff) {
    final resolvedList =
        (puzzles[diff] ?? puzzles[Difficulty.novice]) ?? <Puzzle>[];
    if (resolvedList.isEmpty) {
      current = null;
      selectedCell = null;
      notesMode = false;
      hintsLeft = _maxHints;
      _hintsConsumed = 0;
      livesLeft = _maxLives;
      _history.clear();
      _clearSavedGame();
      _currentGameId = null;
      currentMode = null;
      notifyListeners();
      return;
    }

    _dailyChallengeDate = null;

    final List<Puzzle> available;
    if (diff == Difficulty.novice &&
        resolvedList.length > _novicePuzzleLimit) {
      available = resolvedList.sublist(0, _novicePuzzleLimit);
    } else {
      available = resolvedList;
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
    currentMode = GameMode.classic;
    _sessionId++;
    currentScore = 0;
    selectedCell = null;
    notesMode = false;
    hintsLeft = _maxHints;
    _hintsConsumed = 0;
    livesLeft = _maxLives;
    highlightedNumber = null;
    _madeMistake = false;
    _gameCompleted = false;
    _history.clear();
    _startedAt = DateTime.now();
    _currentGameId = _composeGameId(diff);

    statsByDifficulty[diff]?.gamesStarted++;
    scheduleSave();
    saveProfile();
    notifyListeners();
  }

  void startBattleGame(Difficulty diff) {
    final resolvedList =
        (puzzles[diff] ?? puzzles[Difficulty.novice]) ?? <Puzzle>[];
    if (resolvedList.isEmpty) {
      current = null;
      selectedCell = null;
      notesMode = false;
      hintsLeft = _maxHints;
      _hintsConsumed = 0;
      livesLeft = _maxLives;
      _history.clear();
      _clearSavedGame();
      _currentGameId = null;
      notifyListeners();
      return;
    }

    _dailyChallengeDate = null;

    final List<Puzzle> available;
    if (diff == Difficulty.novice &&
        resolvedList.length > _novicePuzzleLimit) {
      available = resolvedList.sublist(0, _novicePuzzleLimit);
    } else {
      available = resolvedList;
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
    currentMode = GameMode.battle;
    _sessionId++;
    currentScore = 0;
    selectedCell = null;
    notesMode = false;
    hintsLeft = _maxHints;
    _hintsConsumed = 0;
    livesLeft = _maxLives;
    highlightedNumber = null;
    _madeMistake = false;
    _gameCompleted = false;
    _history.clear();
    _startedAt = DateTime.now();
    _currentGameId = _composeGameId(diff);

    scheduleSave();
    notifyListeners();
  }

  /// Перезапуск текущей головоломки без смены задачи.
  void restartCurrentPuzzle() {
    final game = current;
    if (game == null) return;

    for (var i = 0; i < game.board.length; i++) {
      game.board[i] = game.given[i] ? game.solution[i] : 0;
      game.notes[i].clear();
    }

    currentScore = 0;
    selectedCell = null;
    notesMode = false;
    hintsLeft = _maxHints;
    _hintsConsumed = 0;
    livesLeft = _maxLives;
    highlightedNumber = null;
    _madeMistake = false;
    _gameCompleted = false;
    _history.clear();
    _sessionId++;
    _startedAt = DateTime.now();
    final diff = currentDifficulty;
    _currentGameId = diff == null ? null : _composeGameId(diff);

    scheduleSave();
    notifyListeners();
  }

  int get sessionId => _sessionId;

  DateTime? get startedAt => _startedAt;

  String? get currentGameId => _currentGameId;

  String ensureCurrentGameId() {
    final diff = currentDifficulty;
    if (diff == null) {
      final fallback =
          DateTime.now().toUtc().microsecondsSinceEpoch.toString();
      _currentGameId = fallback;
      return fallback;
    }
    final existing = _currentGameId;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = _composeGameId(diff);
    _currentGameId = generated;
    scheduleSave();
    return generated;
  }

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

  DateTime? get activeDailyChallengeDate => _dailyChallengeDate;

  bool isDailyCompleted(DateTime date) {
    return _completedDailyChallenges.contains(_dateKey(_dateOnly(date)));
  }

  int completedDailyCount(DateTime month) {
    final normalized = DateTime(month.year, month.month);
    final prefix =
        '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-';
    return _completedDailyChallenges
        .where((key) => key.startsWith(prefix))
        .length;
  }

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
      _handleMistakeFeedback();
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

    scheduleSave();
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

    scheduleSave();
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
    scheduleSave();
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
    _hintsConsumed++;
    currentScore += 8;
    scheduleSave();
    notifyListeners();
  }

  void toggleNotesMode() {
    if (current == null) return;
    notesMode = !notesMode;
    scheduleSave();
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
      if (_hintsConsumed > 0) {
        _hintsConsumed--;
      }
    }

    if (last.consumedLife) {
      livesLeft = math.min(_maxLives, livesLeft + 1);
    }

    selectedCell = last.index;
    scheduleSave();
    notifyListeners();
  }

  bool grantHint() {
    if (hintsLeft >= _maxHints) {
      return false;
    }
    hintsLeft = math.min(_maxHints, hintsLeft + 1);
    scheduleSave();
    notifyListeners();
    return true;
  }

  void restoreOneLife() {
    livesLeft = math.max(1, livesLeft);
    scheduleSave();
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
    _registerVictory();

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
        stats.progressCurrent += 1;
        if (stats.progressCurrent >= stats.progressTarget) {
          stats.level++;
          stats.rank++;
          stats.progressCurrent = 0;
          stats.progressTarget += stats.level ~/ 2 + 5;
          heartBonus = 1;
        }
      }
    }

    final dailyDate = _dailyChallengeDate;
    if (dailyDate != null) {
      _completeDailyChallenge(dailyDate);
      _dailyChallengeDate = null;
    }

    _clearSavedGame();
    saveProfile();
    notifyListeners();
  }

  void completeBattle(int elapsedMs) {
    final game = current;
    if (game == null) return;
    if (_gameCompleted) return;
    if (!isSolved) return;

    _gameCompleted = true;
    _handleVictoryFeedback();
    _registerVictory();
    battleGamesWon++;
    battleGamesPlayed++;
    game.elapsedMs = elapsedMs;
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
    _dailyChallengeDate = null;
    _clearSavedGame();
    saveProfile();
    notifyListeners();
  }

  void loseBattle() {
    if (currentMode == GameMode.battle) {
      battleGamesPlayed++;
    }
    _handleDefeatFeedback();
    abandonGame();
    saveProfile();
  }

  void abandonGame() {
    current = null;
    currentDifficulty = null;
    currentMode = null;
    currentScore = 0;
    selectedCell = null;
    notesMode = false;
    hintsLeft = _maxHints;
    _hintsConsumed = 0;
    livesLeft = _maxLives;
    _madeMistake = false;
    _gameCompleted = false;
    _history.clear();
    highlightedNumber = null;
    _dailyChallengeDate = null;
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

  bool get canErase {
    final game = current;
    final idx = selectedCell;
    if (game == null || idx == null) return false;
    if (game.given[idx]) return false;
    if (game.board[idx] == 0 && game.notes[idx].isEmpty) return false;
    return true;
  }

  bool get isNotesMode => notesMode;

  bool get canUseHint => hintsLeft > 0;

  int get hintsConsumed => _hintsConsumed;

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

  void _handleMistakeFeedback() {
    _triggerVibration(HapticFeedback.lightImpact);
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

  void _completeDailyChallenge(DateTime date) {
    final normalized = _dateOnly(date);
    final key = _dateKey(normalized);
    final added = _completedDailyChallenges.add(key);
    if (added) {
      _saveDailyProgress();
    }
    _refreshDailyStreak();
  }

  void _saveDailyProgress() {
    final sorted = _completedDailyChallenges.toList()..sort();
    _persist((prefs) async {
      await prefs.setStringList('dailyCompleted', sorted);
    });
  }

  void _refreshDailyStreak() {
    final lastVictory = _lastVictoryDate;
    if (lastVictory == null) {
      dailyStreak = 0;
      return;
    }

    final today = _dateOnly(DateTime.now());
    final normalizedLast = _dateOnly(lastVictory);

    if (normalizedLast.isAfter(today)) {
      dailyStreak = 0;
      _lastVictoryDate = null;
      return;
    }

    if (normalizedLast == today) {
      dailyStreak = math.max(dailyStreak, 1);
      return;
    }

    if (normalizedLast == today.subtract(const Duration(days: 1))) {
      dailyStreak = math.max(dailyStreak, 1);
      return;
    }

    dailyStreak = 0;
  }

  void _registerVictory() {
    _refreshDailyStreak();

    final today = _dateOnly(DateTime.now());
    final lastVictory = _lastVictoryDate == null
        ? null
        : _dateOnly(_lastVictoryDate!);

    if (lastVictory == today) {
      dailyStreak = math.max(dailyStreak, 1);
      return;
    }

    if (lastVictory != null &&
        lastVictory == today.subtract(const Duration(days: 1))) {
      dailyStreak = math.max(0, dailyStreak) + 1;
    } else {
      dailyStreak = 1;
    }

    _lastVictoryDate = today;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> save() async {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await _saveCurrentGame(prefs);
    } catch (e) {
      assert(() {
        debugPrint('AppState.save error: $e');
        return true;
      }());
    }
  }

  void scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: 400),
      () => unawaited(save()),
    );
  }

  Future<void> _saveCurrentGame(SharedPreferences prefs) async {
    final game = current;
    final diff = currentDifficulty;
    final mode = currentMode;
    if (mode == GameMode.battle) {
      await prefs.remove('currentGame');
      return;
    }
    if (game == null || diff == null || _gameCompleted) {
      await prefs.remove('currentGame');
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
      'hintsConsumed': _hintsConsumed,
      'livesLeft': livesLeft,
      'madeMistake': _madeMistake,
      'startedAt': _startedAt?.toIso8601String(),
      'sessionId': _sessionId,
      'history': _history.map((move) => move.toJson()).toList(),
      'dailyDate': _dailyChallengeDate?.toIso8601String(),
      'gameId': _currentGameId,
      'mode': mode?.name,
    };

    await prefs.setString('currentGame', jsonEncode(data));
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
