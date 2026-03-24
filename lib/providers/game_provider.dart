import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sudoku_board.dart';
import '../models/cell.dart';
import '../models/game_stats.dart';
import '../services/sudoku_generator.dart';
import '../services/persistence_service.dart';

enum GameState { idle, playing, paused, completed }

/// Central state for the Sudoku game.
class GameProvider extends ChangeNotifier {
  // ─── Board state ──────────────────────────────────────────────────────────
  SudokuBoard? _board;
  Difficulty _difficulty = Difficulty.easy;
  int? _selectedRow;
  int? _selectedCol;
  bool _notesMode = false;

  // ─── Game state ───────────────────────────────────────────────────────────
  GameState _state = GameState.idle;
  int _mistakes = 0;
  static const int maxMistakes = 3;

  // ─── Timer ────────────────────────────────────────────────────────────────
  Timer? _timer;
  int _elapsedSeconds = 0;

  // ─── Undo / Redo ──────────────────────────────────────────────────────────
  final List<BoardSnapshot> _undoStack = [];
  final List<BoardSnapshot> _redoStack = [];
  static const int maxHistorySize = 50;

  // ─── Stats ────────────────────────────────────────────────────────────────
  GameStats _stats = GameStats();

  // ─── Getters ──────────────────────────────────────────────────────────────
  SudokuBoard? get board => _board;
  Difficulty get difficulty => _difficulty;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  bool get notesMode => _notesMode;
  GameState get state => _state;
  int get mistakes => _mistakes;
  int get elapsedSeconds => _elapsedSeconds;
  GameStats get stats => _stats;
  bool get hasUndo => _undoStack.isNotEmpty;
  bool get hasRedo => _redoStack.isNotEmpty;
  bool get isPlaying => _state == GameState.playing;
  bool get isPaused => _state == GameState.paused;
  bool get isCompleted => _state == GameState.completed;

  String get formattedTime {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  GameProvider() {
    _loadStats();
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> _loadStats() async {
    _stats = await PersistenceService.loadStats();
    notifyListeners();
  }

  /// Starts a brand-new game with the given difficulty.
  Future<void> newGame(Difficulty difficulty) async {
    _stopTimer();
    _difficulty = difficulty;
    _mistakes = 0;
    _elapsedSeconds = 0;
    _undoStack.clear();
    _redoStack.clear();
    _selectedRow = null;
    _selectedCol = null;
    _notesMode = false;
    _state = GameState.playing;

    // Generate puzzle (may take a moment on harder difficulties)
    _board = SudokuGenerator.generate(difficulty);

    _startTimer();
    notifyListeners();
    await _saveGame();
  }

  /// Tries to resume a previously saved game. Returns false if none exists.
  Future<bool> resumeGame() async {
    final saved = await PersistenceService.loadGame();
    if (saved == null) return false;

    _stopTimer();
    _board = saved.board;
    _difficulty = saved.difficulty;
    _elapsedSeconds = saved.elapsedSeconds;
    _mistakes = saved.mistakes;
    _undoStack.clear();
    _redoStack.clear();
    _selectedRow = null;
    _selectedCol = null;
    _notesMode = false;
    _state = GameState.playing;

    _startTimer();
    notifyListeners();
    return true;
  }

  /// Restarts the current puzzle from scratch.
  Future<void> restartGame() async {
    if (_board == null) return;
    _stopTimer();
    _mistakes = 0;
    _elapsedSeconds = 0;
    _undoStack.clear();
    _redoStack.clear();
    _selectedRow = null;
    _selectedCol = null;
    _notesMode = false;
    _state = GameState.playing;

    // Reset all non-given cells
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _board!.cells[r][c];
        if (!cell.isGiven) {
          cell.value = 0;
          cell.notes.clear();
          cell.hasError = false;
        }
      }
    }
    _updateHighlights();
    _startTimer();
    notifyListeners();
    await _saveGame();
  }

  void pauseGame() {
    if (_state != GameState.playing) return;
    _state = GameState.paused;
    _stopTimer();
    notifyListeners();
  }

  void resumeTimer() {
    if (_state != GameState.paused) return;
    _state = GameState.playing;
    _startTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  // ─── Timer ────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ─── Cell Selection ───────────────────────────────────────────────────────

  void selectCell(int row, int col) {
    if (_state != GameState.playing) return;
    _selectedRow = row;
    _selectedCol = col;
    _updateHighlights();
    notifyListeners();
  }

  void _updateHighlights() {
    if (_board == null) return;

    final selRow = _selectedRow;
    final selCol = _selectedCol;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _board!.cells[r][c];
        cell.isSelected = (r == selRow && c == selCol);
        cell.isHighlighted = false;
        cell.isSameValue = false;

        if (selRow != null && selCol != null) {
          // Highlight same row, col, or box
          final sameBox =
              (r ~/ 3 == selRow ~/ 3) && (c ~/ 3 == selCol ~/ 3);
          cell.isHighlighted =
              r == selRow || c == selCol || sameBox;

          // Highlight same value
          final selValue = _board!.cells[selRow][selCol].value;
          if (selValue != 0 && cell.value == selValue) {
            cell.isSameValue = true;
          }
        }
      }
    }
  }

  // ─── Input ────────────────────────────────────────────────────────────────

  Future<void> inputNumber(int number) async {
    if (_state != GameState.playing) return;
    final row = _selectedRow;
    final col = _selectedCol;
    if (row == null || col == null) return;

    final cell = _board!.cells[row][col];
    if (cell.isGiven) return;

    _pushUndo();

    if (_notesMode) {
      // Toggle note
      cell.value = 0;
      cell.hasError = false;
      if (cell.notes.contains(number)) {
        cell.notes.remove(number);
      } else {
        cell.notes.add(number);
      }
    } else {
      // Place number
      cell.notes.clear();
      if (cell.value == number) {
        // Tapping same number clears the cell
        cell.value = 0;
        cell.hasError = false;
      } else {
        cell.value = number;
        // Validate against solution
        if (number != _board!.solution[row][col]) {
          cell.hasError = true;
          _mistakes++;
        } else {
          cell.hasError = false;
          // Auto-remove this number from notes in same row/col/box
          _removeNoteFromRelated(row, col, number);
        }
      }
    }

    _updateHighlights();
    notifyListeners();
    await _checkCompletion();
    await _saveGame();
  }

  /// Removes a note [number] from all related cells (same row/col/box).
  void _removeNoteFromRelated(int row, int col, int number) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (r == row || c == col ||
            (r ~/ 3 == row ~/ 3 && c ~/ 3 == col ~/ 3)) {
          _board!.cells[r][c].notes.remove(number);
        }
      }
    }
  }

  Future<void> clearCell() async {
    if (_state != GameState.playing) return;
    final row = _selectedRow;
    final col = _selectedCol;
    if (row == null || col == null) return;

    final cell = _board!.cells[row][col];
    if (cell.isGiven) return;
    if (cell.value == 0 && cell.notes.isEmpty) return;

    _pushUndo();
    _board!.clearCell(row, col);
    _updateHighlights();
    notifyListeners();
    await _saveGame();
  }

  void toggleNotesMode() {
    _notesMode = !_notesMode;
    notifyListeners();
  }

  // ─── Hint ─────────────────────────────────────────────────────────────────

  Future<void> giveHint() async {
    if (_state != GameState.playing || _board == null) return;

    // Find selected empty cell first, then any empty cell
    int? hintRow = _selectedRow;
    int? hintCol = _selectedCol;

    if (hintRow != null && hintCol != null) {
      final cell = _board!.cells[hintRow][hintCol];
      if (cell.isGiven || cell.value == _board!.solution[hintRow][hintCol]) {
        hintRow = null;
        hintCol = null;
      }
    }

    if (hintRow == null || hintCol == null) {
      // Find any incorrect/empty cell
      outer:
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final cell = _board!.cells[r][c];
          if (!cell.isGiven && cell.value != _board!.solution[r][c]) {
            hintRow = r;
            hintCol = c;
            break outer;
          }
        }
      }
    }

    if (hintRow == null || hintCol == null) return;

    _pushUndo();
    final cell = _board!.cells[hintRow][hintCol];
    cell.value = _board!.solution[hintRow][hintCol];
    cell.hasError = false;
    cell.notes.clear();
    _selectedRow = hintRow;
    _selectedCol = hintCol;
    _removeNoteFromRelated(hintRow, hintCol, cell.value);
    _updateHighlights();
    notifyListeners();
    await _checkCompletion();
    await _saveGame();
  }

  // ─── Undo / Redo ──────────────────────────────────────────────────────────

  void _pushUndo() {
    if (_board == null) return;
    _undoStack.add(BoardSnapshot(_board!.cells));
    if (_undoStack.length > maxHistorySize) _undoStack.removeAt(0);
    _redoStack.clear(); // New action clears redo
  }

  void undo() {
    if (_board == null || _undoStack.isEmpty) return;
    _redoStack.add(BoardSnapshot(_board!.cells));
    final snapshot = _undoStack.removeLast();
    _restoreSnapshot(snapshot);
  }

  void redo() {
    if (_board == null || _redoStack.isEmpty) return;
    _undoStack.add(BoardSnapshot(_board!.cells));
    final snapshot = _redoStack.removeLast();
    _restoreSnapshot(snapshot);
  }

  void _restoreSnapshot(BoardSnapshot snapshot) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final src = snapshot.cells[r][c];
        final dst = _board!.cells[r][c];
        dst.value = src.value;
        dst.hasError = src.hasError;
        dst.notes
          ..clear()
          ..addAll(src.notes);
      }
    }
    _updateHighlights();
    notifyListeners();
  }

  // ─── Completion ───────────────────────────────────────────────────────────

  Future<void> _checkCompletion() async {
    if (_board == null) return;
    if (_board!.isSolved) {
      _stopTimer();
      _state = GameState.completed;
      _stats = _stats.updateBestTime(_difficulty, _elapsedSeconds);
      _stats = _stats.recordWin(_difficulty);
      await PersistenceService.saveStats(_stats);
      await PersistenceService.clearGame();
      notifyListeners();
    }
  }

  // ─── Persistence ──────────────────────────────────────────────────────────

  Future<void> _saveGame() async {
    if (_board == null || _state == GameState.completed) return;
    await PersistenceService.saveGame(
      board: _board!,
      difficulty: _difficulty,
      elapsedSeconds: _elapsedSeconds,
      mistakes: _mistakes,
    );
  }

  Future<void> clearStats() async {
    _stats = GameStats();
    await PersistenceService.clearStats();
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Returns the solution value for a given cell (for UI hints).
  int? solutionAt(int row, int col) => _board?.solution[row][col];

  /// Number of filled cells.
  int get filledCount {
    if (_board == null) return 0;
    int count = 0;
    for (final row in _board!.cells) {
      for (final cell in row) {
        if (cell.value != 0) count++;
      }
    }
    return count;
  }

  bool get hasSavedGame => false; // Updated async at start

  Future<bool> checkSavedGame() => PersistenceService.loadGame()
      .then((saved) => saved != null);
}
