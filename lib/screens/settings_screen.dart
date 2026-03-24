import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sudoku_board.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = context.watch<ThemeProvider>();
    final game = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ───────────────────────────────────────────────────
          _SectionHeader('Appearance'),
          _SettingsCard(children: [
            _ToggleTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: theme.isDark,
              onChanged: (_) => theme.toggleDark(),
            ),
          ]),

          // ── Gameplay ─────────────────────────────────────────────────────
          _SectionHeader('Gameplay'),
          _SettingsCard(children: [
            _ToggleTile(
              icon: Icons.grid_view_rounded,
              title: 'Highlight Assistance',
              subtitle: 'Highlight related row, column & box',
              value: settings.highlightAssistance,
              onChanged: settings.setHighlightAssistance,
            ),
            const Divider(height: 1, indent: 56),
            _ToggleTile(
              icon: Icons.filter_9_plus_rounded,
              title: 'Highlight Same Numbers',
              subtitle: 'Highlight all cells with same value',
              value: settings.highlightSameNumber,
              onChanged: settings.setHighlightSameNumber,
            ),
            const Divider(height: 1, indent: 56),
            _ToggleTile(
              icon: Icons.edit_note_rounded,
              title: 'Auto-remove Notes',
              subtitle: 'Remove pencil marks when placing a number',
              value: settings.autoRemoveNotes,
              onChanged: settings.setAutoRemoveNotes,
            ),
          ]),

          // ── Sound ────────────────────────────────────────────────────────
          _SectionHeader('Sound'),
          _SettingsCard(children: [
            _ToggleTile(
              icon: settings.soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              title: 'Sound Effects',
              value: settings.soundEnabled,
              onChanged: settings.setSoundEnabled,
            ),
          ]),

          // ── Default Difficulty ────────────────────────────────────────────
          _SectionHeader('Default Difficulty'),
          _SettingsCard(children: [
            ...Difficulty.values.map(
              (d) => _RadioTile(
                title: d.label,
                groupValue: settings.defaultDifficulty,
                value: d,
                onChanged: (v) => settings.setDefaultDifficulty(v!),
              ),
            ),
          ]),

          // ── Statistics ────────────────────────────────────────────────────
          _SectionHeader('Statistics'),
          _StatsCard(stats: game.stats),

          const SizedBox(height: 16),

          // Reset stats
          OutlinedButton.icon(
            onPressed: () => _confirmResetStats(context, game),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Reset Statistics'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // App info
          Center(
            child: Text(
              'Sudoku v1.0.0',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmResetStats(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Statistics?'),
        content:
            const Text('All best times and game history will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              game.clearStats();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: children),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon,
          color: Theme.of(context).colorScheme.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12))
          : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

class _RadioTile<T> extends StatelessWidget {
  final String title;
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;

  const _RadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}

class _StatsCard extends StatelessWidget {
  final dynamic stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              children: [
                _tableHeader(''),
                _tableHeader('Played'),
                _tableHeader('Won'),
                _tableHeader('Best'),
              ],
            ),
            ...Difficulty.values.map(
              (d) => TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(d.label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                _tableCell('${stats.gamesPlayed[d] ?? 0}'),
                _tableCell('${stats.gamesWon[d] ?? 0}'),
                _tableCell(stats.formatBestTime(d)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5),
          textAlign: TextAlign.center,
        ),
      );

  Widget _tableCell(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      );
}
