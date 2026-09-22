import 'package:flutter/material.dart';

/// One carrot per focus session in the current cycle.
class SessionDots extends StatelessWidget {
  const SessionDots({super.key, required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Opacity(
              opacity: i < completed ? 1 : 0.2,
              child: const Text('🥕', style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }
}
