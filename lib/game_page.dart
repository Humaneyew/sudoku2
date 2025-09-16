import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models.dart';
import 'widgets/board.dart';
import 'widgets/control_panel.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Timer? _timer;
  int elapsedMs = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        elapsedMs += 1000;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int ms) {
    final seconds = ms ~/ 1000;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final game = app.current;

    if (game == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Игра"),
        ),
        body: const Center(
          child: Text("Нет активной игры. Вернитесь на главный экран."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Судоку"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            "⏱ ${_formatTime(elapsedMs)}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // игровая доска
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Board(),
          ),

          const SizedBox(height: 16),

          // панель управления
          ControlPanel(
            onNumberSelected: (number) {
              if (app.selectedCell != null) {
                app.makeMove(app.selectedCell!, number);
              }
            },
          ),
        ],
      ),
    );
  }
}
