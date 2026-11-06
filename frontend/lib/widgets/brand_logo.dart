import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class BrandLogo extends StatelessWidget {
  final bool light;
  final VoidCallback? onTap;
  final double scale;

  const BrandLogo({
    super.key,
    this.light = false,
    this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : AppColors.navy;
    final subColor = light ? const Color(0xFFAEB8C2) : AppColors.slate;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rotated Gold Diamond with inner Gold Center
        SizedBox(
          width: 32 * scale,
          height: 32 * scale,
          child: Center(
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 20 * scale,
                height: 20 * scale,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold, width: 1.6),
                ),
                child: Center(
                  child: Container(
                    width: 8 * scale,
                    height: 8 * scale,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 11 * scale),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FIRSTHOME',
              style: GoogleFonts.manrope(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: textColor,
                height: 1.0,
              ),
            ),
            SizedBox(height: 3 * scale),
            Text(
              'NIGERIA',
              style: GoogleFonts.inter(
                fontSize: 7.5 * scale,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.8,
                color: subColor,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: content,
        ),
      );
    }
    return content;
  }
}

