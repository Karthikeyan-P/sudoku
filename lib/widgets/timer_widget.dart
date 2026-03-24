import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

/// Displays the formatted elapsed game time in the app bar.
class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final cs = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        game.isPaused ? 'Paused' : game.formattedTime,
        key: ValueKey(game.isPaused),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
