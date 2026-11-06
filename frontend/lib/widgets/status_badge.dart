import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        icon = Icons.phone_forwarded_outlined;
        break;
      case 'qualified':
        bg = AppColors.statusQualifiedBg;
        fg = AppColors.statusQualifiedText;
        icon = Icons.check_circle_outline;
        break;
      case 'closed':
        bg = AppColors.statusClosedBg;
        fg = AppColors.statusClosedText;
        icon = Icons.done_all_outlined;
        break;
      default:
        bg = AppColors.statusClosedBg;
        fg = AppColors.statusClosedText;
        icon = Icons.circle_outlined;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: fg.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 13, color: fg),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.manrope(
              color: fg,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
