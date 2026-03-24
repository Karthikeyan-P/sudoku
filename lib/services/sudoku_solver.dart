/// Sudoku solver using recursive backtracking.
/// Used both to verify unique solutions and to provide hints.
class SudokuSolver {
  /// Attempts to solve [grid] in-place.
  /// Returns true if a solution was found.
  static bool solve(List<List<int>> grid) {
    final empty = _findEmpty(grid);
    if (empty == null) return true; // All cells filled — solved!

    final row = empty[0];
    final col = empty[1];

    for (int num = 1; num <= 9; num++) {
      if (_isValid(grid, row, col, num)) {
        grid[row][col] = num;
        if (solve(grid)) return true;
        grid[row][col] = 0; // Backtrack
      }
    }

    return false; // Trigger backtrack
  }

  /// Returns true if [grid] has exactly one unique solution.
  /// Stops early as soon as a second solution is found.
  static bool hasUniqueSolution(List<List<int>> grid) {
    final copy = _copyGrid(grid);
    return _countSolutions(copy, 0) == 1;
  }

  /// Counts solutions up to [limit] (default 2, for uniqueness check).
  static int _countSolutions(List<List<int>> grid, int count,
      {int limit = 2}) {
    if (count >= limit) return count;

    final empty = _findEmpty(grid);
    if (empty == null) return count + 1; // Found a solution

    final row = empty[0];
    final col = empty[1];

    for (int num = 1; num <= 9; num++) {
      if (_isValid(grid, row, col, num)) {
        grid[row][col] = num;
        count = _countSolutions(grid, count, limit: limit);
        grid[row][col] = 0;
        if (count >= limit) return count;
      }
    }

    return count;
  }

  /// Finds the first empty cell (value == 0) using MRV heuristic.
  /// Returns [row, col] or null if no empty cells.
  static List<int>? _findEmpty(List<List<int>> grid) {
    int minOptions = 10;
    List<int>? best;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          int options = 0;
          for (int n = 1; n <= 9; n++) {
            if (_isValid(grid, r, c, n)) options++;
          }
          if (options < minOptions) {
            minOptions = options;
            best = [r, c];
            if (minOptions == 0) return best; // No options — dead end
          }
        }
      }
    }
    return best;
  }

  /// Checks if placing [num] at [row],[col] is valid.
  static bool _isValid(List<List<int>> grid, int row, int col, int num) {
    // Row check
    for (int c = 0; c < 9; c++) {
      if (grid[row][c] == num) return false;
    }

    // Column check
    for (int r = 0; r < 9; r++) {
      if (grid[r][col] == num) return false;
    }

    // 3x3 box check
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }

    return true;
  }

  /// Deep copies a 9x9 grid.
  static List<List<int>> _copyGrid(List<List<int>> grid) =>
      List.generate(9, (r) => List<int>.from(grid[r]));

  /// Returns a solved copy of [grid], or null if no solution exists.
  static List<List<int>>? solvedCopy(List<List<int>> grid) {
    final copy = _copyGrid(grid);
    if (solve(copy)) return copy;
    return null;
  }
}
