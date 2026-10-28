import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class VerificationBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const VerificationBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'verified':
        bg = AppColors.verifVerifiedBg;
        fg = AppColors.verifVerifiedText;
        icon = Icons.verified;
        label = 'Verified';
        break;
      case 'pending':
        bg = AppColors.verifPendingBg;
        fg = AppColors.verifPendingText;
        icon = Icons.hourglass_top_outlined;
        label = 'Pending';
        break;
      case 'rejected':
        bg = AppColors.verifRejectedBg;
        fg = AppColors.verifRejectedText;
        icon = Icons.cancel_outlined;
        label = 'Rejected';
        break;
      case 'notstarted':
      default:
        bg = AppColors.verifNotStartedBg;
        fg = AppColors.verifNotStartedText;
        icon = Icons.shield_outlined;
        label = 'Unverified';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              compact && label.contains(' ') ? label.split(' ')[0] : label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
