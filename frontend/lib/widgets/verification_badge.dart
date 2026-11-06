import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        icon = Icons.verified_user_outlined;
        label = 'Verified';
        break;
      case 'pending':
        bg = AppColors.verifPendingBg;
        fg = AppColors.verifPendingText;
        icon = Icons.hourglass_empty_outlined;
        label = 'Pending';
        break;
      case 'rejected':
        bg = AppColors.verifRejectedBg;
        fg = AppColors.verifRejectedText;
        icon = Icons.error_outline;
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
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: fg.withValues(alpha: 0.18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: fg,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
