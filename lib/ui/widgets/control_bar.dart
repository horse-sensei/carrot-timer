import 'package:flutter/material.dart';

import '../../domain/pomodoro_phase.dart';
import '../theme.dart';

class ControlBar extends StatelessWidget {
  const ControlBar({
    super.key,
    required this.isRunning,
    required this.canStop,
    required this.phase,
    required this.onToggle,
    required this.onStop,
  });

  final bool isRunning;
  final bool canStop;
  final PomodoroPhase phase;
  final VoidCallback onToggle;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final accent = CarrotColors.forPhase(phase);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          key: const ValueKey('play_pause'),
          onPressed: onToggle,
          tooltip: isRunning ? '일시정지' : '재생',
          iconSize: 20,
          constraints: const BoxConstraints.tightFor(width: 36, height: 32),
          style: IconButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: CarrotColors.soil,
          ),
          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
        ),
        const SizedBox(width: 8),
        IconButton(
          key: const ValueKey('stop'),
          onPressed: canStop ? onStop : null,
          tooltip: '정지',
          iconSize: 20,
          constraints: const BoxConstraints.tightFor(width: 36, height: 32),
          style: IconButton.styleFrom(
            foregroundColor: CarrotColors.cream,
            disabledForegroundColor: CarrotColors.cream.withValues(alpha: 0.25),
            backgroundColor: CarrotColors.soilLight,
          ),
          icon: const Icon(Icons.stop),
        ),
      ],
    );
  }
}
