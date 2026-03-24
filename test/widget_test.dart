import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_app/main.dart';
import 'package:sudoku_app/providers/game_provider.dart';
import 'package:sudoku_app/providers/settings_provider.dart';
import 'package:sudoku_app/providers/theme_provider.dart';
import 'package:sudoku_app/screens/home_screen.dart';
import 'package:sudoku_app/widgets/sudoku_grid.dart';
import 'package:sudoku_app/models/sudoku_board.dart';

Widget _buildApp(Widget home) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        home: home,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
      ),
    );

void main() {
  group('HomeScreen', () {
    testWidgets('shows difficulty buttons', (tester) async {
      await tester.pumpWidget(_buildApp(const HomeScreen()));
      await tester.pump();

      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
    });

    testWidgets('shows Sudoku title', (tester) async {
      await tester.pumpWidget(_buildApp(const HomeScreen()));
      await tester.pump();

      expect(find.text('Sudoku'), findsOneWidget);
    });

    testWidgets('settings icon is present', (tester) async {
      await tester.pumpWidget(_buildApp(const HomeScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });
  });

  group('SudokuGrid', () {
    testWidgets('renders 81 cells when board is loaded', (tester) async {
      final gameProvider = GameProvider();
      await gameProvider.newGame(Difficulty.easy);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: gameProvider),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SudokuGrid()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // 81 cells in the grid
      expect(find.byType(GestureDetector),
          findsAtLeast(81));
    });
  });
}
