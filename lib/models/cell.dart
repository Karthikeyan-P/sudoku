/// Represents a single cell in the Sudoku grid.
class Cell {
  /// The actual value of the cell (0 means empty).
  int value;

  /// Whether this cell was part of the original puzzle (cannot be changed).
  final bool isGiven;

  /// User-entered notes/pencil marks (possible values 1-9).
  final Set<int> notes;

  /// Whether the cell has an error (user entered wrong value).
  bool hasError;

  /// Whether the cell is highlighted (related row/col/box).
  bool isHighlighted;

  /// Whether the cell is selected.
  bool isSelected;

  /// Whether the cell shares the same value as selected cell.
  bool isSameValue;

  Cell({
    this.value = 0,
    this.isGiven = false,
    Set<int>? notes,
    this.hasError = false,
    this.isHighlighted = false,
    this.isSelected = false,
    this.isSameValue = false,
  }) : notes = notes ?? {};

  /// Returns true if the cell is empty.
  bool get isEmpty => value == 0;

  /// Returns true if the cell has notes.
  bool get hasNotes => notes.isNotEmpty;

  /// Creates a deep copy of this cell.
  Cell copyWith({
    int? value,
    bool? isGiven,
    Set<int>? notes,
    bool? hasError,
    bool? isHighlighted,
    bool? isSelected,
    bool? isSameValue,
  }) {
    return Cell(
      value: value ?? this.value,
      isGiven: isGiven ?? this.isGiven,
      notes: notes ?? Set.from(this.notes),
      hasError: hasError ?? this.hasError,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isSelected: isSelected ?? this.isSelected,
      isSameValue: isSameValue ?? this.isSameValue,
    );
  }

  /// Serializes to a map for persistence.
  Map<String, dynamic> toJson() => {
        'value': value,
        'isGiven': isGiven,
        'notes': notes.toList(),
        'hasError': hasError,
      };

  /// Deserializes from a map.
  factory Cell.fromJson(Map<String, dynamic> json) => Cell(
        value: json['value'] as int,
        isGiven: json['isGiven'] as bool,
        notes: Set<int>.from((json['notes'] as List).cast<int>()),
        hasError: json['hasError'] as bool,
      );

  @override
  String toString() => 'Cell(value: $value, isGiven: $isGiven)';
}
