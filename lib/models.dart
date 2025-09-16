import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'puzzles.dart';

/// Уровни сложности
enum Difficulty { beginner, medium, high, expert, master }

extension DifficultyX on Difficulty {
  String get title => switch (this) {
    Difficulty.beginner => "Новичок",
    Difficulty.medium => "Средний",
    Difficulty.high => "Высокий",
    Difficulty.expert => "Эксперт",
    Difficulty.master => "Мастер",
  };
}

/// Темы приложения
enum AppTheme { system, light, dark }

/// Поддерживаемые языки
enum AppLanguage { en, ru, uk, de, fr, zh, hi }

extension AppLanguageX on AppLanguage {
  String get nameLocal => switch (this) {
    AppLanguage.en => "English",
    AppLanguage.ru => "Русский",
    AppLanguage.uk => "Українська",
    AppLanguage.de => "Deutsch",
    AppLanguage.fr => "Français",
    AppLanguage.zh => "中文",
    AppLanguage.hi => "हिन्दी",
  };
}

/// Класс состояния игры
class GameState {
  final List<int> board;
  final List<int> solution;
  final List<bool> given;

  GameState({
    required this.board,
    required this.solution,
    required this.given,
  });
}

/// Статистика игрока
class Stats {
  int gamesPlayed;
  int gamesWon;
  int bestTimeMs;
  int totalTimeMs;
  int streak;
  int bestStreak;

  Stats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.bestTimeMs = 0,
    this.totalTimeMs = 0,
    this.streak = 0,
    this.bestStreak = 0,
  });

  double get winRate =>
      gamesPlayed == 0 ? 0 : gamesWon / gamesPlayed;

  String get bestTimeText =>
      bestTimeMs == 0 ? "-" : _fmt(bestTimeMs);

  String get avgTimeText =>
      gamesWon == 0 ? "-" : _fmt(totalTimeMs ~/ gamesWon);

  int get rank => (gamesWon ~/ 5) + 1;

  static String _fmt(int ms) {
    final sec = ms ~/ 1000;
    final min = sec ~/ 60;
    final s = sec % 60;
    return "${min}m ${s}s";
  }

  Map<String, dynamic> toJson() => {
    "gamesPlayed": gamesPlayed,
    "gamesWon": gamesWon,
    "bestTimeMs": bestTimeMs,
    "totalTimeMs": totalTimeMs,
    "streak": streak,
    "bestStreak": bestStreak,
  };

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    gamesPlayed: json["gamesPlayed"] ?? 0,
    gamesWon: json["gamesWon"] ?? 0,
    bestTimeMs: json["bestTimeMs"] ?? 0,
    totalTimeMs: json["totalTimeMs"] ?? 0,
    streak: json["streak"] ?? 0,
    bestStreak: json["bestStreak"] ?? 0,
  );
}

/// Главное состояние приложения
class AppState extends ChangeNotifier {
  static const int _maxHints = 3;

  AppTheme theme = AppTheme.system;
  AppLanguage lang = AppLanguage.en;
  GameState? current;
  Stats stats = Stats();

  int? selectedCell;
  bool notesMode = false;
  int hintsLeft = _maxHints;
  bool soundsEnabled = true;
  bool musicEnabled = true;

  final List<_Move> _history = [];

  /// Загружаем сохранённые данные
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString("stats");
    if (statsJson != null) {
      stats = Stats.fromJson(jsonDecode(statsJson));
    }

    final themeName = prefs.getString("theme");
    if (themeName != null) {
      try {
        theme = AppTheme.values.byName(themeName);
      } catch (_) {}
    }

    final langName = prefs.getString("lang");
    if (langName != null) {
      try {
        lang = AppLanguage.values.byName(langName);
      } catch (_) {}
    }

    soundsEnabled = prefs.getBool("soundsEnabled") ?? soundsEnabled;
    musicEnabled = prefs.getBool("musicEnabled") ?? musicEnabled;
    notifyListeners();
  }

  /// Сохраняем статистику
  Future<void> saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("stats", jsonEncode(stats.toJson()));
  }

  /// Сброс статистики
  void resetStats() {
    stats = Stats();
    saveStats();
    notifyListeners();
  }

  void setTheme(AppTheme value) {
    if (theme == value) return;
    theme = value;
    _persist((prefs) async {
      await prefs.setString("theme", value.name);
    });
    notifyListeners();
  }

  void setLang(AppLanguage value) {
    if (lang == value) return;
    lang = value;
    _persist((prefs) async {
      await prefs.setString("lang", value.name);
    });
    notifyListeners();
  }

  void toggleSounds(bool enabled) {
    if (soundsEnabled == enabled) return;
    soundsEnabled = enabled;
    _persist((prefs) async {
      await prefs.setBool("soundsEnabled", enabled);
    });
    notifyListeners();
  }

  void toggleMusic(bool enabled) {
    if (musicEnabled == enabled) return;
    musicEnabled = enabled;
    _persist((prefs) async {
      await prefs.setBool("musicEnabled", enabled);
    });
    notifyListeners();
  }

  /// Запуск новой игры
  void startGame(Difficulty diff) {
    final available = puzzles[diff];
    if (available == null || available.isEmpty) {
      current = null;
      selectedCell = null;
      notesMode = false;
      hintsLeft = _maxHints;
      _history.clear();
      notifyListeners();
      return;
    }

    final puzzle = available.first;
    current = GameState(
      board: List.of(puzzle.board),
      solution: List.of(puzzle.solution),
      given: puzzle.board.map((v) => v != 0).toList(),
    );

    selectedCell = null;
    notesMode = false;
    hintsLeft = _maxHints;
    _history.clear();

    notifyListeners();
  }

  /// Проверка правильности хода
  bool isMoveValid(int index, int value) {
    if (current == null) return false;
    return current!.solution[index] == value;
  }

  /// Сделать ход
  void makeMove(int index, int value) {
    if (current == null) return;
    if (current!.given[index]) return;

    final previous = current!.board[index];
    if (previous == value) return;

    _history.add(_Move(index, previous));
    current!.board[index] = value;
    notifyListeners();
  }

  /// Выбрать ячейку
  void selectCell(int index) {
    selectedCell = index;
    notifyListeners();
  }

  /// Стереть значение
  void eraseCell() {
    if (current == null || selectedCell == null) return;
    if (current!.given[selectedCell!]) return;

    final idx = selectedCell!;
    final previous = current!.board[idx];
    if (previous == 0) return;

    _history.add(_Move(idx, previous));
    current!.board[idx] = 0;
    notifyListeners();
  }

  /// Подсказка
  void useHint() {
    if (current == null || selectedCell == null) return;
    if (hintsLeft <= 0) return;
    if (current!.given[selectedCell!]) return;

    final idx = selectedCell!;
    final previous = current!.board[idx];
    final correct = current!.solution[idx];
    if (previous == correct) return;

    _history.add(_Move(idx, previous, consumedHint: true));
    current!.board[idx] = correct;
    hintsLeft--;

    notifyListeners();
  }

  /// Переключение заметок
  void toggleNotesMode() {
    notesMode = !notesMode;
    notifyListeners();
  }

  /// Отмена последнего хода
  void undoMove() {
    if (current == null || _history.isEmpty) return;

    final last = _history.removeLast();
    if (current!.given[last.index]) {
      return;
    }

    current!.board[last.index] = last.previousValue;
    selectedCell = last.index;
    if (last.consumedHint && hintsLeft < _maxHints) {
      hintsLeft++;
    }
    notifyListeners();
  }

  /// Подсчёт оставшихся чисел
  int countRemaining(int number) {
    if (current == null) return 9;
    return 9 - current!.board.where((v) => v == number).length;
  }

  void _persist(Future<void> Function(SharedPreferences prefs) save) {
    SharedPreferences.getInstance().then(save);
  }
}

class _Move {
  final int index;
  final int previousValue;
  final bool consumedHint;

  _Move(this.index, this.previousValue, {this.consumedHint = false});
}
