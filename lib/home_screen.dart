import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models.dart';
import 'game_screen.dart';
import 'stats_page.dart';
import 'settings_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sudoku"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Выберите уровень сложности:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildLevelButton(context, "Новичок", Difficulty.beginner, Colors.green),
          _buildLevelButton(context, "Средний", Difficulty.medium, Colors.blue),
          _buildLevelButton(context, "Высокий", Difficulty.high, Colors.orange),
          _buildLevelButton(context, "Эксперт", Difficulty.expert, Colors.redAccent),
          _buildLevelButton(context, "Мастер", Difficulty.master, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildLevelButton(
      BuildContext context, String title, Difficulty diff, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          final app = context.read<AppState>();
          app.startGame(diff);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GameScreen()),
          );
        },
        child: Text(title, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
