import 'dart:math';
import '../models/sudoku_board.dart';
import '../models/cell.dart';
import 'sudoku_solver.dart';

/// Generates Sudoku puzzles of varying difficulty.
class SudokuGenerator {
  static final Random _rng = Random();

  /// Generates a new puzzle board for the given [difficulty].
  static SudokuBoard generate(Difficulty difficulty) {
    // Step 1: Create a fully filled valid grid.
    final solution = _generateFullGrid();

    // Step 2: Copy the solution as the starting puzzle.
    final puzzle = List.generate(9, (r) => List<int>.from(solution[r]));

    // Step 3: Randomly remove cells while keeping unique solution.
    _removeCells(puzzle, difficulty.cellsToRemove);

    // Step 4: Build Cell objects from puzzle and solution.
    final cells = List.generate(
      9,
      (r) => List.generate(
        9,
        (c) => Cell(
          value: puzzle[r][c],
          isGiven: puzzle[r][c] != 0,
        ),
      ),
    );

    return SudokuBoard(cells: cells, solution: solution);
  }

  /// Creates a fully filled valid Sudoku grid using backtracking with
  /// random number ordering to produce different puzzles each time.
  static List<List<int>> _generateFullGrid() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  /// Recursive backtracking fill with shuffled candidates.
  static bool _fillGrid(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          final numbers = _shuffled([1, 2, 3, 4, 5, 6, 7, 8, 9]);
          for (final num in numbers) {
            if (_isValid(grid, r, c, num)) {
              grid[r][c] = num;
              if (_fillGrid(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false; // Backtrack
        }
      }
    }
    return true; // All cells filled
  }

  /// Removes [count] cells from the grid while maintaining a unique solution.
  static void _removeCells(List<List<int>> grid, int count) {
    // Build list of all positions and shuffle them.
    final positions = <List<int>>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add([r, c]);
      }
    }
    positions.shuffle(_rng);

    int removed = 0;
    for (final pos in positions) {
      if (removed >= count) break;

      final r = pos[0];
      final c = pos[1];
      final backup = grid[r][c];

      grid[r][c] = 0;

      // Verify the puzzle still has a unique solution.
      if (SudokuSolver.hasUniqueSolution(grid)) {
        removed++;
      } else {
        // Restore if removing breaks uniqueness.
        grid[r][c] = backup;
      }
    }
  }

  /// Validates placement in the raw grid (not Cell-based).
  static bool _isValid(List<List<int>> grid, int row, int col, int num) {
    for (int c = 0; c < 9; c++) {
      if (grid[row][c] == num) return false;
    }
    for (int r = 0; r < 9; r++) {
      if (grid[r][col] == num) return false;
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }
    return true;
  }

  /// Returns a shuffled copy of [list].
  static List<T> _shuffled<T>(List<T> list) {
    final copy = List<T>.from(list);
    copy.shuffle(_rng);
    return copy;
  }
}
