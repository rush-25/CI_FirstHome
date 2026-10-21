import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'new':
        bg = AppColors.statusNewBg;
        fg = AppColors.statusNewText;
        icon = Icons.fiber_new_outlined;
        break;
      case 'contacted':
        bg = AppColors.statusContactedBg;
        fg = AppColors.statusContactedText;
        icon = Icons.phone_in_talk_outlined;
        break;
      case 'qualified':
        bg = AppColors.statusQualifiedBg;
        fg = AppColors.statusQualifiedText;
        icon = Icons.check_circle_outline;
        break;
      case 'closed':
        bg = AppColors.statusClosedBg;
        fg = AppColors.statusClosedText;
        icon = Icons.archive_outlined;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
        icon = Icons.circle_outlined;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
