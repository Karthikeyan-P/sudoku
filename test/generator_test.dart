import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/models/sudoku_board.dart';
import 'package:sudoku_app/services/sudoku_generator.dart';
import 'package:sudoku_app/services/sudoku_solver.dart';

void main() {
  group('SudokuGenerator', () {
    for (final difficulty in Difficulty.values) {
      test('generates valid ${difficulty.label} puzzle', () {
        final board = SudokuGenerator.generate(difficulty);

        // Board must not be null
        expect(board, isNotNull);

        // Solution must be valid (check rows, cols, boxes all 1-9)
        for (int r = 0; r < 9; r++) {
          final row = board.solution[r].toSet();
          expect(row.length, equals(9),
              reason: 'Row $r has duplicate values');
          expect(row, containsAll([1, 2, 3, 4, 5, 6, 7, 8, 9]));
        }
        for (int c = 0; c < 9; c++) {
          final col = {for (int r = 0; r < 9; r++) board.solution[r][c]};
          expect(col.length, equals(9),
              reason: 'Col $c has duplicate values');
        }
        for (int br = 0; br < 3; br++) {
          for (int bc = 0; bc < 3; bc++) {
            final box = <int>{};
            for (int r = br * 3; r < br * 3 + 3; r++) {
              for (int c = bc * 3; c < bc * 3 + 3; c++) {
                box.add(board.solution[r][c]);
              }
            }
            expect(box.length, equals(9),
                reason: 'Box [$br,$bc] has duplicate values');
          }
        }

        // Puzzle has approximately the right number of empty cells
        final emptyCells = board.emptyCellCount;
        expect(emptyCells, greaterThanOrEqualTo(difficulty.cellsToRemove - 10),
            reason: 'Too few empty cells for ${difficulty.label}');

        // Puzzle has unique solution
        final puzzleGrid = List.generate(
          9,
          (r) => List.generate(9, (c) => board.cells[r][c].value),
        );
        expect(SudokuSolver.hasUniqueSolution(puzzleGrid), isTrue,
            reason: '${difficulty.label} puzzle should have unique solution');
      });
    }

    test('given cells match solution values', () {
      final board = SudokuGenerator.generate(Difficulty.easy);
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final cell = board.cells[r][c];
          if (cell.isGiven) {
            expect(cell.value, equals(board.solution[r][c]),
                reason: 'Given cell [$r,$c] does not match solution');
          }
        }
      }
    });

    test('non-given cells start empty', () {
      final board = SudokuGenerator.generate(Difficulty.medium);
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final cell = board.cells[r][c];
          if (!cell.isGiven) {
            expect(cell.value, equals(0),
                reason: 'Non-given cell [$r,$c] should start empty');
          }
        }
      }
    });
  });
}
