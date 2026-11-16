import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  (Color, Color) get _palette {
    switch (status.toLowerCase()) {
      case 'alive':
        return (AppColors.alive, AppColors.aliveSoft);
      case 'dead':
        return (AppColors.dead, AppColors.deadSoft);
      default:
        return (AppColors.unknown, AppColors.unknownSoft);
    }
  }

  String get _displayStatus {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _palette;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8.5 : 11,
        vertical: compact ? 3.5 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6.5 : 7.5,
            height: compact ? 6.5 : 7.5,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5.5),
          Text(
            _displayStatus,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 11.5 : 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
