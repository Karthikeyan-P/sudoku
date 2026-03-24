import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import 'sudoku_cell.dart';

/// Renders the full 9×9 Sudoku board with thick 3×3 box borders.
class SudokuGrid extends StatelessWidget {
  const SudokuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();
    final cs = Theme.of(context).colorScheme;

    if (game.board == null) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cs.onSurface.withOpacity(0.3),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CustomPaint(
            foregroundPainter: _GridLinePainter(color: cs.onSurface),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                final cell = game.board!.cells[row][col];

                return SudokuCell(
                  row: row,
                  col: col,
                  cell: cell,
                  showHighlight: settings.highlightAssistance,
                  showSameValue: settings.highlightSameNumber,
                  onTap: () => game.selectCell(row, col),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the thick 3×3 box dividing lines on top of the grid cells.
class _GridLinePainter extends CustomPainter {
  final Color color;
  _GridLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final thickPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    final thinPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 0.8;

    final cellSize = size.width / 9;

    for (int i = 1; i < 9; i++) {
      final paint = (i % 3 == 0) ? thickPaint : thinPaint;
      final x = i * cellSize;
      final y = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridLinePainter old) => old.color != color;
}
