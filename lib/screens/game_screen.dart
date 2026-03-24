import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../widgets/timer_widget.dart';
import '../widgets/game_controls.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack(context, game);
      },
      child: Scaffold(
        appBar: _buildAppBar(context, game),
        body: SafeArea(
          child: game.board == null
              ? const Center(child: CircularProgressIndicator())
              : _GameBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, GameProvider game) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => _onBack(context, game),
      ),
      title: Column(
        children: [
          Text(
            game.difficulty.label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const TimerWidget(),
        ],
      ),
      centerTitle: true,
      actions: [
        // Pause / Resume
        if (game.isPlaying)
          IconButton(
            icon: const Icon(Icons.pause_rounded),
            onPressed: game.pauseGame,
            tooltip: 'Pause',
          )
        else if (game.isPaused)
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            onPressed: game.resumeTimer,
            tooltip: 'Resume',
          ),
        // Hint
        IconButton(
          icon: const Icon(Icons.lightbulb_outline_rounded),
          onPressed: game.isPlaying ? game.giveHint : null,
          tooltip: 'Hint',
        ),
      ],
    );
  }

  void _onBack(BuildContext context, GameProvider game) {
    if (game.isPaused || game.isPlaying) {
      game.pauseGame();
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Game?'),
        content: const Text(
            'Your progress will be saved. You can resume this game later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    ).then((_) {
      // Resume timer if they cancelled
      if (game.isPaused) game.resumeTimer();
    });
  }
}

class _GameBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Stack(
      children: [
        Column(
          children: [
            // Mistake counter
            _MistakesBar(mistakes: game.mistakes),

            // Progress bar
            _ProgressBar(),

            const SizedBox(height: 8),

            // Main grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const SudokuGrid(),
            ),

            const SizedBox(height: 12),

            // Game controls (undo, redo, erase, notes)
            const GameControls(),

            const SizedBox(height: 8),

            // Number pad
            const NumberPad(),

            const SizedBox(height: 16),
          ],
        ),

        // Pause overlay
        if (game.isPaused) _PauseOverlay(),

        // Completion overlay
        if (game.isCompleted)
          _CompletionOverlay(
            elapsedSeconds: game.elapsedSeconds,
            difficulty: game.difficulty.label,
            mistakes: game.mistakes,
          ),
      ],
    );
  }
}

class _MistakesBar extends StatelessWidget {
  final int mistakes;
  const _MistakesBar({required this.mistakes});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Mistakes: ',
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          ...List.generate(
            GameProvider.maxMistakes,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                i < mistakes ? Icons.close_rounded : Icons.circle_outlined,
                size: 18,
                color: i < mistakes ? cs.error : cs.onSurface.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final total = 81;
    final given = game.board?.cells
            .expand((r) => r)
            .where((c) => c.isGiven)
            .length ??
        0;
    final editable = total - given;
    final filled = game.filledCount - given;
    final progress = editable > 0 ? (filled / editable).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pause_circle_outline_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Paused',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: game.resumeTimer,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Resume'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionOverlay extends StatelessWidget {
  final int elapsedSeconds;
  final String difficulty;
  final int mistakes;

  const _CompletionOverlay({
    required this.elapsedSeconds,
    required this.difficulty,
    required this.mistakes,
  });

  String get _formattedTime {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface.withOpacity(0.97),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon with animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 56,
                    color: Colors.amber.shade700,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Puzzle Solved!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                difficulty,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 32),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(
                    icon: Icons.timer_outlined,
                    label: 'Time',
                    value: _formattedTime,
                  ),
                  _Stat(
                    icon: Icons.close_rounded,
                    label: 'Mistakes',
                    value: '$mistakes',
                    valueColor: mistakes > 0 ? cs.error : Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () {
                  context.read<GameProvider>().newGame(
                        context.read<GameProvider>().difficulty,
                      );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: cs.primary, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: valueColor ?? cs.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
