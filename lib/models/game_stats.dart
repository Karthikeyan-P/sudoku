import 'sudoku_board.dart';

/// Stores per-difficulty best times and game counts.
class GameStats {
  final Map<Difficulty, int?> bestTimes; // seconds
  final Map<Difficulty, int> gamesPlayed;
  final Map<Difficulty, int> gamesWon;

  GameStats({
    Map<Difficulty, int?>? bestTimes,
    Map<Difficulty, int>? gamesPlayed,
    Map<Difficulty, int>? gamesWon,
  })  : bestTimes = bestTimes ??
            {
              Difficulty.easy: null,
              Difficulty.medium: null,
              Difficulty.hard: null,
            },
        gamesPlayed = gamesPlayed ??
            {
              Difficulty.easy: 0,
              Difficulty.medium: 0,
              Difficulty.hard: 0,
            },
        gamesWon = gamesWon ??
            {
              Difficulty.easy: 0,
              Difficulty.medium: 0,
              Difficulty.hard: 0,
            };

  /// Updates best time for the given difficulty if new time is faster.
  GameStats updateBestTime(Difficulty difficulty, int seconds) {
    final current = bestTimes[difficulty];
    final newBestTimes = Map<Difficulty, int?>.from(bestTimes);
    if (current == null || seconds < current) {
      newBestTimes[difficulty] = seconds;
    }
    return GameStats(
      bestTimes: newBestTimes,
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
    );
  }

  /// Increments played and won counts.
  GameStats recordWin(Difficulty difficulty) {
    final newPlayed = Map<Difficulty, int>.from(gamesPlayed);
    final newWon = Map<Difficulty, int>.from(gamesWon);
    newPlayed[difficulty] = (newPlayed[difficulty] ?? 0) + 1;
    newWon[difficulty] = (newWon[difficulty] ?? 0) + 1;
    return GameStats(
      bestTimes: bestTimes,
      gamesPlayed: newPlayed,
      gamesWon: newWon,
    );
  }

  /// Increments only played count (game abandoned or failed).
  GameStats recordPlay(Difficulty difficulty) {
    final newPlayed = Map<Difficulty, int>.from(gamesPlayed);
    newPlayed[difficulty] = (newPlayed[difficulty] ?? 0) + 1;
    return GameStats(
      bestTimes: bestTimes,
      gamesPlayed: newPlayed,
      gamesWon: gamesWon,
    );
  }

  String formatBestTime(Difficulty difficulty) {
    final seconds = bestTimes[difficulty];
    if (seconds == null) return '--:--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'bestTimes': {
          'easy': bestTimes[Difficulty.easy],
          'medium': bestTimes[Difficulty.medium],
          'hard': bestTimes[Difficulty.hard],
        },
        'gamesPlayed': {
          'easy': gamesPlayed[Difficulty.easy],
          'medium': gamesPlayed[Difficulty.medium],
          'hard': gamesPlayed[Difficulty.hard],
        },
        'gamesWon': {
          'easy': gamesWon[Difficulty.easy],
          'medium': gamesWon[Difficulty.medium],
          'hard': gamesWon[Difficulty.hard],
        },
      };

  factory GameStats.fromJson(Map<String, dynamic> json) {
    final bt = json['bestTimes'] as Map<String, dynamic>?;
    final gp = json['gamesPlayed'] as Map<String, dynamic>?;
    final gw = json['gamesWon'] as Map<String, dynamic>?;

    return GameStats(
      bestTimes: {
        Difficulty.easy: bt?['easy'] as int?,
        Difficulty.medium: bt?['medium'] as int?,
        Difficulty.hard: bt?['hard'] as int?,
      },
      gamesPlayed: {
        Difficulty.easy: (gp?['easy'] as int?) ?? 0,
        Difficulty.medium: (gp?['medium'] as int?) ?? 0,
        Difficulty.hard: (gp?['hard'] as int?) ?? 0,
      },
      gamesWon: {
        Difficulty.easy: (gw?['easy'] as int?) ?? 0,
        Difficulty.medium: (gw?['medium'] as int?) ?? 0,
        Difficulty.hard: (gw?['hard'] as int?) ?? 0,
      },
    );
  }
}
