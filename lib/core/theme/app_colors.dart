import 'package:flutter/material.dart';

class AppColors {
  // Primary: Apple-like blue, away from dating-app coral.
  static const Color primary = Color(0xFF0A84FF);
  static const Color primaryDark = Color(0xFF0057D9);
  static const Color primaryLight = Color(0xFF64D2FF);
  static const Color primarySoft = Color(0xFFE8F3FF);

  // Accent: fresh cyan/green for gaming energy.
  static const Color accent = Color(0xFF00C7BE);
  static const Color accentDark = Color(0xFF009C95);
  static const Color accentLight = Color(0xFFDDF9F7);

  // Secondary alias for backward compatibility.
  static const Color secondary = accent;

  // Gaming highlights.
  static const Color neonGreen = Color(0xFF32D74B);
  static const Color neonPurple = Color(0xFFBF5AF2);
  static const Color neonOrange = Color(0xFFFF9F0A);

  // Surfaces.
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFBFCFF);
  static const Color glass = Color(0xCCFFFFFF);
  static const Color divider = Color(0xFFE7ECF4);

  // Text.
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Neutral greys.
  static const Color grey900 = Color(0xFF111827);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey50 = Color(0xFFF9FAFB);

  // Status.
  static const Color success = Color(0xFF32D74B);
  static const Color error = Color(0xFFFF453A);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color info = Color(0xFF0A84FF);
  static const Color online = Color(0xFF32D74B);
  static const Color offline = Color(0xFF9CA3AF);

  // Swipe action colors.
  static const Color swipeLike = Color(0xFF32D74B);
  static const Color swipeNope = Color(0xFF8E8E93);
  static const Color swipeSuperLike = Color(0xFFFF9F0A);

  // Bottom nav.
  static const Color navBarBackground = Color(0xFFFFFFFF);
  static const Color navBarActive = Color(0xFF0A84FF);
  static const Color navBarInactive = Color(0xFF9AA4B2);

  // Gradients.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF00C7BE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFF8FBFF), Color(0xFFEAF6FF), Color(0xFFEAFBF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x12000000),
      Color(0x99000000),
      Color(0xE6000000),
    ],
    stops: [0.0, 0.36, 0.72, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF32D74B), Color(0xFF00C7BE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1D3557).withValues(alpha: 0.12),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF1D3557).withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.24),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];
}
