import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sudoku_board.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _hasSavedGame = false;
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoController.forward();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final has =
        await context.read<GameProvider>().checkSavedGame();
    if (mounted) setState(() => _hasSavedGame = has);
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = context.watch<SettingsProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ),
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                  ),
                  IconButton(
                    onPressed: () => themeProvider.toggleDark(),
                    icon: Icon(themeProvider.isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined),
                    tooltip: 'Toggle theme',
                  ),
                ],
              ),

              const Spacer(),

              // Logo
              ScaleTransition(
                scale: _logoAnimation,
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _MiniGrid(color: colorScheme.onPrimary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sudoku',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Train your brain',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Difficulty selection
              Text(
                'Choose Difficulty',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Difficulty buttons
              ...Difficulty.values.map(
                (d) => _DifficultyButton(
                  difficulty: d,
                  isDefault: d == settings.defaultDifficulty,
                  onTap: () => _startGame(d),
                ),
              ),

              if (_hasSavedGame) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _resumeGame,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Continue Game'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(Difficulty difficulty) {
    context.read<GameProvider>().newGame(difficulty).then((_) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      ).then((_) => _checkSavedGame());
    });
  }

  void _resumeGame() {
    context.read<GameProvider>().resumeGame().then((ok) {
      if (!mounted || !ok) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen()),
      ).then((_) => _checkSavedGame());
    });
  }
}

class _DifficultyButton extends StatelessWidget {
  final Difficulty difficulty;
  final bool isDefault;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.difficulty,
    required this.isDefault,
    required this.onTap,
  });

  Color _color(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (difficulty) {
      Difficulty.easy => Colors.green,
      Difficulty.medium => Colors.orange,
      Difficulty.hard => cs.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            color: isDefault ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(isDefault ? 0 : 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                difficulty.label,
                style: TextStyle(
                  color: isDefault ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tiny decorative 3x3 mini-grid for the logo.
class _MiniGrid extends StatelessWidget {
  final Color color;
  const _MiniGrid({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(
        painter: _MiniGridPainter(color: color),
      ),
    );
  }
}

class _MiniGridPainter extends CustomPainter {
  final Color color;
  _MiniGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final step = size.width / 3;
    for (int i = 0; i <= 3; i++) {
      final isBold = i % 3 == 0;
      paint.strokeWidth = isBold ? 2.5 : 1;
      canvas.drawLine(Offset(i * step, 0), Offset(i * step, size.height), paint);
      canvas.drawLine(Offset(0, i * step), Offset(size.width, i * step), paint);
    }
  }

  @override
  bool shouldRepaint(_MiniGridPainter old) => old.color != color;
}
