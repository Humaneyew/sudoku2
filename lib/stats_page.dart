import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final stats = app.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Статистика"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTile("Игр сыграно", stats.gamesPlayed.toString()),
          _buildTile("Побед", stats.gamesWon.toString()),
          _buildTile("Процент побед", "${(stats.winRate * 100).toStringAsFixed(1)}%"),
          _buildTile("Лучшее время", stats.bestTimeText),
          _buildTile("Среднее время", stats.avgTimeText),
          _buildTile("Текущая серия", stats.streak.toString()),
          _buildTile("Лучшая серия", stats.bestStreak.toString()),
          _buildTile("Ранг", stats.rank.toString()),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              app.resetStats();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Статистика сброшена")),
              );
            },
            child: const Text("Сбросить статистику"),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
