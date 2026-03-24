import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sudoku_board.dart';
import '../models/game_stats.dart';

/// Handles all local persistence using SharedPreferences.
class PersistenceService {
  static const _keyBoard = 'saved_board';
  static const _keyDifficulty = 'saved_difficulty';
  static const _keyElapsed = 'saved_elapsed';
  static const _keyMistakes = 'saved_mistakes';
  static const _keyStats = 'game_stats';
  static const _keySettings = 'app_settings';

  // ─── Board Persistence ────────────────────────────────────────────────────

  /// Saves the current game state.
  static Future<void> saveGame({
    required SudokuBoard board,
    required Difficulty difficulty,
    required int elapsedSeconds,
    required int mistakes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBoard, jsonEncode(board.toJson()));
    await prefs.setString(_keyDifficulty, difficulty.name);
    await prefs.setInt(_keyElapsed, elapsedSeconds);
    await prefs.setInt(_keyMistakes, mistakes);
  }

  /// Loads a previously saved game, or returns null.
  static Future<SavedGame?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final boardJson = prefs.getString(_keyBoard);
    final diffStr = prefs.getString(_keyDifficulty);
    final elapsed = prefs.getInt(_keyElapsed);
    final mistakes = prefs.getInt(_keyMistakes);

    if (boardJson == null || diffStr == null) return null;

    try {
      final board =
          SudokuBoard.fromJson(jsonDecode(boardJson) as Map<String, dynamic>);
      final difficulty =
          Difficulty.values.firstWhere((d) => d.name == diffStr);
      return SavedGame(
        board: board,
        difficulty: difficulty,
        elapsedSeconds: elapsed ?? 0,
        mistakes: mistakes ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  /// Clears saved game data.
  static Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBoard);
    await prefs.remove(_keyDifficulty);
    await prefs.remove(_keyElapsed);
    await prefs.remove(_keyMistakes);
  }

  // ─── Stats ────────────────────────────────────────────────────────────────

  static Future<void> saveStats(GameStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStats, jsonEncode(stats.toJson()));
  }

  static Future<GameStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyStats);
    if (json == null) return GameStats();
    try {
      return GameStats.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return GameStats();
    }
  }

  static Future<void> clearStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStats);
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(settings));
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keySettings);
    if (json == null) return {};
    try {
      return Map<String, dynamic>.from(
          jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return {};
    }
  }
}

/// Data class for a saved game.
class SavedGame {
  final SudokuBoard board;
  final Difficulty difficulty;
  final int elapsedSeconds;
  final int mistakes;

  const SavedGame({
    required this.board,
    required this.difficulty,
    required this.elapsedSeconds,
    required this.mistakes,
  });
}
