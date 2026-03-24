import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

/// Number input pad (1–9) displayed below the Sudoku grid.
class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final board = game.board;

    // Count how many times each number (1-9) appears in the board
    final counts = List.filled(10, 0); // index 0 unused
    if (board != null) {
      for (final row in board.cells) {
        for (final cell in row) {
          if (cell.value > 0) counts[cell.value]++;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(9, (i) {
          final num = i + 1;
          final count = counts[num];
          final complete = count >= 9; // All 9 instances placed
          return Expanded(
            child: _NumberKey(
              number: num,
              isComplete: complete,
              isDisabled: complete || !game.isPlaying,
              onTap: () => game.inputNumber(num),
            ),
          );
        }),
      ),
    );
  }
}

class _NumberKey extends StatelessWidget {
  final int number;
  final bool isComplete;
  final bool isDisabled;
  final VoidCallback onTap;

  const _NumberKey({
    required this.number,
    required this.isComplete,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isComplete
                  ? cs.surfaceContainerHighest.withOpacity(0.4)
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isComplete
                      ? cs.onSurface.withOpacity(0.2)
                      : isDisabled
                          ? cs.onSurface.withOpacity(0.3)
                          : cs.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
