import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

/// Row of action buttons: Undo, Erase, Notes Mode, Redo, Restart.
class GameControls extends StatelessWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            onTap: game.hasUndo && game.isPlaying ? game.undo : null,
          ),
          _ControlButton(
            icon: Icons.backspace_outlined,
            label: 'Erase',
            onTap: game.isPlaying ? game.clearCell : null,
          ),
          _NotesModeButton(
            active: game.notesMode,
            onTap: game.isPlaying ? game.toggleNotesMode : null,
          ),
          _ControlButton(
            icon: Icons.redo_rounded,
            label: 'Redo',
            onTap: game.hasRedo && game.isPlaying ? game.redo : null,
          ),
          _ControlButton(
            icon: Icons.refresh_rounded,
            label: 'Restart',
            onTap: game.isPlaying
                ? () => _confirmRestart(context, game)
                : null,
          ),
        ],
      ),
    );
  }

  void _confirmRestart(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart Puzzle?'),
        content: const Text(
            'All your progress will be lost and the timer will reset.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              game.restartGame();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: enabled
                  ? cs.surfaceContainerHighest
                  : cs.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: enabled
                  ? cs.onSurface
                  : cs.onSurface.withOpacity(0.25),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: enabled
                  ? cs.onSurface.withOpacity(0.7)
                  : cs.onSurface.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesModeButton extends StatelessWidget {
  final bool active;
  final VoidCallback? onTap;

  const _NotesModeButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 22,
              color: active
                  ? cs.onPrimary
                  : enabled
                      ? cs.onSurface
                      : cs.onSurface.withOpacity(0.25),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: active
                  ? cs.primary
                  : enabled
                      ? cs.onSurface.withOpacity(0.7)
                      : cs.onSurface.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }
}
