// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sudoku2/main.dart';
import 'package:sudoku2/models.dart';
import 'package:sudoku2/undo_reward_controller.dart';

void main() {
  testWidgets('Домашний экран отображает основные секции', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('uk');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(
            create: (_) => UndoRewardController(enabled: false),
          ),
        ],
        child: const SudokuApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Судоку Майстер'), findsOneWidget);
    expect(find.text('Нова гра'), findsOneWidget);
  });
}
