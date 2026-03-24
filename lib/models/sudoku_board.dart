import 'cell.dart';

/// Difficulty levels for puzzle generation.
enum Difficulty {
  easy(35, 'Easy'),
  medium(45, 'Medium'),
  hard(55, 'Hard');

  /// Number of cells to remove when generating puzzle.
  final int cellsToRemove;
  final String label;

  const Difficulty(this.cellsToRemove, this.label);
}

/// Snapshot used for undo/redo history.
class BoardSnapshot {
  final List<List<Cell>> cells;

  BoardSnapshot(List<List<Cell>> source)
      : cells = List.generate(
          9,
          (r) => List.generate(9, (c) => source[r][c].copyWith()),
        );
}

/// The main Sudoku board model containing all 81 cells.
class SudokuBoard {
  /// 9x9 grid of cells.
  final List<List<Cell>> cells;

  /// The complete solution for the current puzzle.
  final List<List<int>> solution;

  SudokuBoard({
    required this.cells,
    required this.solution,
  });

  /// Creates an empty board.
  factory SudokuBoard.empty() => SudokuBoard(
        cells: List.generate(
          9,
          (_) => List.generate(9, (_) => Cell()),
        ),
        solution: List.generate(9, (_) => List.filled(9, 0)),
      );

  /// Gets cell at [row], [col].
  Cell getCell(int row, int col) => cells[row][col];

  /// Sets the value of a non-given cell.
  void setValue(int row, int col, int value) {
    if (!cells[row][col].isGiven) {
      cells[row][col].value = value;
    }
  }

  /// Toggles a note on a non-given cell.
  void toggleNote(int row, int col, int note) {
    if (!cells[row][col].isGiven) {
      final cell = cells[row][col];
      if (cell.notes.contains(note)) {
        cell.notes.remove(note);
      } else {
        cell.notes.add(note);
      }
    }
  }

  /// Clears value and notes of a non-given cell.
  void clearCell(int row, int col) {
    if (!cells[row][col].isGiven) {
      cells[row][col].value = 0;
      cells[row][col].notes.clear();
      cells[row][col].hasError = false;
    }
  }

  /// Validates placement — checks if [value] conflicts in row/col/box.
  bool isValidPlacement(int row, int col, int value) {
    if (value == 0) return true;

    // Check row
    for (int c = 0; c < 9; c++) {
      if (c != col && cells[row][c].value == value) return false;
    }

    // Check column
    for (int r = 0; r < 9; r++) {
      if (r != row && cells[r][col].value == value) return false;
    }

    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && cells[r][c].value == value) return false;
      }
    }

    return true;
  }

  /// Returns true if the puzzle is fully and correctly solved.
  bool get isSolved {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (cells[r][c].value != solution[r][c]) return false;
      }
    }
    return true;
  }

  /// Returns number of empty (non-given) cells remaining.
  int get emptyCellCount {
    int count = 0;
    for (final row in cells) {
      for (final cell in row) {
        if (cell.isEmpty) count++;
      }
    }
    return count;
  }

  /// Validates all cells and marks errors.
  void validateAll() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = cells[r][c];
        if (!cell.isGiven && cell.value != 0) {
          cell.hasError = cell.value != solution[r][c];
        }
      }
    }
  }

  /// Creates a deep copy of the board.
  SudokuBoard copy() => SudokuBoard(
        cells: List.generate(
          9,
          (r) => List.generate(9, (c) => cells[r][c].copyWith()),
        ),
        solution: List.generate(9, (r) => List.from(solution[r])),
      );

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
        'cells': cells
            .map((row) => row.map((cell) => cell.toJson()).toList())
            .toList(),
        'solution': solution,
      };

  /// Deserializes from JSON map.
  factory SudokuBoard.fromJson(Map<String, dynamic> json) {
    final cellsJson = json['cells'] as List;
    final solutionJson = json['solution'] as List;

    return SudokuBoard(
      cells: List.generate(
        9,
        (r) => List.generate(
          9,
          (c) => Cell.fromJson(cellsJson[r][c] as Map<String, dynamic>),
        ),
      ),
      solution: List.generate(
        9,
        (r) => List<int>.from((solutionJson[r] as List).cast<int>()),
      ),
    );
  }
}
