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
  AppTheme theme = AppTheme.system;
  AppLanguage lang = AppLanguage.en;
  GameState? current;
  Stats stats = Stats();

  int? selectedCell;
  bool notesMode = false;
  int hintsLeft = 3;

  /// Загружаем сохранённые данные
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString("stats");
    if (statsJson != null) {
      stats = Stats.fromJson(jsonDecode(statsJson));
    }
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

  /// Запуск новой игры
  void startGame(Difficulty diff) {
    final givens = puzzles[diff]!.first;
    final solution = solutions[diff]!.first;

    current = GameState(
      board: List.of(givens),
      solution: List.of(solution),
      given: givens.map((v) => v != 0).toList(),
    );

    selectedCell = null;
    notesMode = false;
    hintsLeft = 3;

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

    current!.board[selectedCell!] = 0;
    notifyListeners();
  }

  /// Подсказка
  void useHint() {
    if (current == null || selectedCell == null) return;
    if (hintsLeft <= 0) return;

    final idx = selectedCell!;
    current!.board[idx] = current!.solution[idx];
    hintsLeft--;

    notifyListeners();
  }

  /// Переключение заметок
  void toggleNotesMode() {
    notesMode = !notesMode;
    notifyListeners();
  }

  /// Подсчёт оставшихся чисел
  int countRemaining(int number) {
    if (current == null) return 9;
    return 9 - current!.board.where((v) => v == number).length;
  }
}
