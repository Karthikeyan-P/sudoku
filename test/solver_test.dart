import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/services/sudoku_solver.dart';

void main() {
  group('SudokuSolver', () {
    // A well-known Sudoku puzzle and its solution
    final puzzle = [
      [5, 3, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 0, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9],
    ];

    final solution = [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ];

    test('solve() finds correct solution', () {
      final grid =
          List.generate(9, (r) => List<int>.from(puzzle[r]));
      expect(SudokuSolver.solve(grid), isTrue);
      expect(grid, equals(solution));
    });

    test('solve() returns false for unsolvable grid', () {
      final bad = List.generate(9, (_) => List.filled(9, 0));
      // Put two 1s in the same row — impossible
      bad[0][0] = 1;
      bad[0][1] = 1;
      expect(SudokuSolver.solve(bad), isFalse);
    });

    test('hasUniqueSolution() is true for well-formed puzzle', () {
      final grid =
          List.generate(9, (r) => List<int>.from(puzzle[r]));
      expect(SudokuSolver.hasUniqueSolution(grid), isTrue);
    });

    test('hasUniqueSolution() is false for over-constrained removal', () {
      // Completely empty board has many solutions
      final empty = List.generate(9, (_) => List.filled(9, 0));
      expect(SudokuSolver.hasUniqueSolution(empty), isFalse);
    });

    test('solvedCopy() returns non-null for solvable grid', () {
      final grid =
          List.generate(9, (r) => List<int>.from(puzzle[r]));
      final solved = SudokuSolver.solvedCopy(grid);
      expect(solved, isNotNull);
      expect(solved, equals(solution));
    });

    test('solvedCopy() does not modify original grid', () {
      final grid =
          List.generate(9, (r) => List<int>.from(puzzle[r]));
      final original = List.generate(9, (r) => List<int>.from(puzzle[r]));
      SudokuSolver.solvedCopy(grid);
      expect(grid, equals(original));
    });
  });
}
