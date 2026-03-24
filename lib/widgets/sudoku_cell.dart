import 'package:flutter/material.dart';
import '../models/cell.dart';

/// A single cell widget in the Sudoku grid.
class SudokuCell extends StatelessWidget {
  final int row;
  final int col;
  final Cell cell;
  final bool showHighlight;
  final bool showSameValue;
  final VoidCallback onTap;

  const SudokuCell({
    super.key,
    required this.row,
    required this.col,
    required this.cell,
    required this.showHighlight,
    required this.showSameValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background color logic
    Color bg;
    if (cell.isSelected) {
      bg = cs.primary.withOpacity(0.25);
    } else if (showSameValue && cell.isSameValue) {
      bg = cs.primary.withOpacity(0.18);
    } else if (showHighlight && cell.isHighlighted) {
      bg = isDark
          ? cs.onSurface.withOpacity(0.06)
          : cs.primary.withOpacity(0.06);
    } else {
      bg = Colors.transparent;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: bg,
        child: Center(
          child: cell.value != 0
              ? _buildValue(context, cs)
              : cell.hasNotes
                  ? _buildNotes(context, cs)
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildValue(BuildContext context, ColorScheme cs) {
    Color color;
    if (cell.hasError) {
      color = cs.error;
    } else if (cell.isGiven) {
      color = cs.onSurface;
    } else {
      color = cs.primary;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = constraints.maxWidth * 0.52;
        return AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: cell.isGiven ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
          child: Text(
            '${cell.value}',
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildNotes(BuildContext context, ColorScheme cs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final noteSize = constraints.maxWidth * 0.28;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 9,
          itemBuilder: (_, i) {
            final num = i + 1;
            final hasNote = cell.notes.contains(num);
            return Center(
              child: hasNote
                  ? Text(
                      '$num',
                      style: TextStyle(
                        fontSize: noteSize,
                        fontWeight: FontWeight.w500,
                        color: cs.primary.withOpacity(0.7),
                        height: 1,
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
