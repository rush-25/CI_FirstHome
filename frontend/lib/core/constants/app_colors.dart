import 'package:flutter/material.dart';

class AppColors {
  // Brand Foundation (FirstHome Figma Editorial Luxury Palette)
  static const Color navy = Color(0xFF101C2C); // Midnight Navy (Primary)
  static const Color deep = Color(0xFF17283B); // Deep Navy Slate
  static const Color gold = Color(0xFFC7A66A); // Warm Architectural Gold
  static const Color goldLight = Color(0xFFF7F2E7); // Warm Light Gold Tint
  static const Color ivory = Color(0xFFF8F7F3); // Warm Ivory Background
  static const Color slate = Color(0xFF687586); // Slate Caption & Secondary Text
  static const Color border = Color(0xFFE9E7E1); // Hairline Warm Border
  static const Color borderStrong = Color(0xFFD4D8DC); // Strong Border

  // Primary semantic aliases
  static const Color primary = navy;
  static const Color primaryDark = Color(0xFF0B1521); // Footer / Darkest Navy
  static const Color primaryLight = deep;
  static const Color background = ivory;
  static const Color surface = Colors.white;
  static const Color surfaceMuted = ivory;

  // Typography & Neutrals
  static const Color textPrimary = navy;
  static const Color textSecondary = slate;
  static const Color textTertiary = Color(0xFF8F9AA5);

  // Semantic Alerts & Accents
  static const Color success = Color(0xFF27866A); // Deep Pine / Verified Green
  static const Color successBg = Color(0xFFE8F4EF);
  static const Color warning = Color(0xFFA67123); // Warm Amber
  static const Color warningBg = Color(0xFFFCF2E3);
  static const Color error = Color(0xFFC93B2B); // Crimson Red
  static const Color errorBg = Color(0xFFFBEEED);
  static const Color info = Color(0xFF2D5E9B); // Soft Navy Blue
  static const Color infoBg = Color(0xFFEEF3FA);

  // Legacy aliases
  static const Color sage = Color(0xFFE8EFEA);
  static const Color sageLight = Color(0xFFF2F6F3);

  // Status Badges (Leads)
  static const Color statusNewBg = Color(0xFFEEF3FA);
  static const Color statusNewText = Color(0xFF2D5E9B);
  static const Color statusContactedBg = Color(0xFFFCF2E3);
  static const Color statusContactedText = Color(0xFFA67123);
  static const Color statusQualifiedBg = Color(0xFFE8F4EF);
  static const Color statusQualifiedText = Color(0xFF27866A);
  static const Color statusClosedBg = Color(0xFFF0F2F5);
  static const Color statusClosedText = Color(0xFF687586);

  // Verification Badges
  static const Color verifVerifiedBg = Color(0xFFE8F4EF);
  static const Color verifVerifiedText = Color(0xFF27866A);
  static const Color verifPendingBg = Color(0xFFFCF2E3);
  static const Color verifPendingText = Color(0xFFA67123);
  static const Color verifRejectedBg = Color(0xFFFBEEED);
  static const Color verifRejectedText = Color(0xFFC93B2B);
  static const Color verifNotStartedBg = Color(0xFFF0F2F5);
  static const Color verifNotStartedText = Color(0xFF687586);
}
