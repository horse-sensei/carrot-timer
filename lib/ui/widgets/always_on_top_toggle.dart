import 'package:flutter/material.dart';

import '../theme.dart';

class AlwaysOnTopToggle extends StatelessWidget {
  const AlwaysOnTopToggle({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('pin'),
      onPressed: () => onChanged(!enabled),
      tooltip: enabled ? '고정 해제' : '화면에 고정 (항상 위 + 모든 Space)',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 24, height: 24),
      iconSize: 16,
      icon: Icon(
        enabled ? Icons.push_pin : Icons.push_pin_outlined,
        color: enabled
            ? CarrotColors.carrot
            : CarrotColors.cream.withValues(alpha: 0.45),
      ),
    );
  }
}
