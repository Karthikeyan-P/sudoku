import 'package:flutter/material.dart';
import '../models/sudoku_board.dart';
import '../services/persistence_service.dart';

/// Manages user preferences for the app.
class SettingsProvider extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _highlightAssistance = true;
  bool _highlightSameNumber = true;
  bool _autoRemoveNotes = true;
  Difficulty _defaultDifficulty = Difficulty.easy;

  bool get soundEnabled => _soundEnabled;
  bool get highlightAssistance => _highlightAssistance;
  bool get highlightSameNumber => _highlightSameNumber;
  bool get autoRemoveNotes => _autoRemoveNotes;
  Difficulty get defaultDifficulty => _defaultDifficulty;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final settings = await PersistenceService.loadSettings();
    _soundEnabled = (settings['soundEnabled'] as bool?) ?? true;
    _highlightAssistance = (settings['highlightAssistance'] as bool?) ?? true;
    _highlightSameNumber = (settings['highlightSameNumber'] as bool?) ?? true;
    _autoRemoveNotes = (settings['autoRemoveNotes'] as bool?) ?? true;
    final diffName = settings['defaultDifficulty'] as String?;
    if (diffName != null) {
      _defaultDifficulty = Difficulty.values.firstWhere(
        (d) => d.name == diffName,
        orElse: () => Difficulty.easy,
      );
    }
    notifyListeners();
  }

  Future<void> _save() async {
    await PersistenceService.saveSettings({
      'soundEnabled': _soundEnabled,
      'highlightAssistance': _highlightAssistance,
      'highlightSameNumber': _highlightSameNumber,
      'autoRemoveNotes': _autoRemoveNotes,
      'defaultDifficulty': _defaultDifficulty.name,
    });
  }

  Future<void> setSoundEnabled(bool val) async {
    _soundEnabled = val;
    notifyListeners();
    await _save();
  }

  Future<void> setHighlightAssistance(bool val) async {
    _highlightAssistance = val;
    notifyListeners();
    await _save();
  }

  Future<void> setHighlightSameNumber(bool val) async {
    _highlightSameNumber = val;
    notifyListeners();
    await _save();
  }

  Future<void> setAutoRemoveNotes(bool val) async {
    _autoRemoveNotes = val;
    notifyListeners();
    await _save();
  }

  Future<void> setDefaultDifficulty(Difficulty d) async {
    _defaultDifficulty = d;
    notifyListeners();
    await _save();
  }
}
