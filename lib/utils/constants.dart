import 'package:flutter/material.dart';

class AppColors {
  // Surface colors
  static const Color surface = Color(0xFFf8f9fa);
  static const Color surfaceDim = Color(0xFFd9dadb);
  static const Color surfaceBright = Color(0xFFf8f9fa);
  static const Color surfaceContainerLowest = Color(0xFFffffff);
  static const Color surfaceContainerLow = Color(0xFFf3f4f5);
  static const Color surfaceContainer = Color(0xFFedeeef);
  static const Color surfaceContainerHigh = Color(0xFFe7e8e9);
  static const Color surfaceContainerHighest = Color(0xFFe1e3e4);

  // On-surface colors
  static const Color onSurface = Color(0xFF191c1d);
  static const Color onSurfaceVariant = Color(0xFF404752);

  // Primary colors
  static const Color primary = Color(0xFF0061a4);
  static const Color onPrimary = Color(0xFFffffff);
  static const Color primaryContainer = Color(0xFF2196f3);
  static const Color onPrimaryContainer = Color(0xFF002c4f);
  static const Color primaryFixed = Color(0xFFd1e4ff);
  static const Color primaryFixedDim = Color(0xFF9ecaff);
  static const Color onPrimaryFixed = Color(0xFF001d36);
  static const Color onPrimaryFixedVariant = Color(0xFF00497d);

  // Secondary (Success/Green)
  static const Color secondary = Color(0xFF006e1c);
  static const Color onSecondary = Color(0xFFffffff);
  static const Color secondaryContainer = Color(0xFF91f78e);
  static const Color onSecondaryContainer = Color(0xFF00731e);
  static const Color secondaryFixed = Color(0xFF94f990);
  static const Color secondaryFixedDim = Color(0xFF78dc77);
  static const Color onSecondaryFixed = Color(0xFF002204);
  static const Color onSecondaryFixedVariant = Color(0xFF005313);

  // Tertiary
  static const Color tertiary = Color(0xFF8b5000);
  static const Color tertiaryContainer = Color(0xFFd37d00);

  // Error
  static const Color error = Color(0xFFba1a1a);
  static const Color onError = Color(0xFFffffff);
  static const Color errorContainer = Color(0xFFffdad6);
  static const Color onErrorContainer = Color(0xFF93000a);

  // Outline
  static const Color outline = Color(0xFF707883);
  static const Color outlineVariant = Color(0xFFbfc7d4);

  // Background
  static const Color background = Color(0xFFf8f9fa);
  static const Color onBackground = Color(0xFF191c1d);
  static const Color surfaceVariant = Color(0xFFe1e3e4);
  static const Color inverseSurface = Color(0xFF2e3132);
  static const Color inverseOnSurface = Color(0xFFf0f1f2);
  static const Color inversePrimary = Color(0xFF9ecaff);
  static const Color surfaceTint = Color(0xFF0061a4);
}

class AppTypography {
  static const String headlineFont = 'Hanken Grotesk';
  static const String bodyFont = 'Inter';

  static const TextStyle displayLg = TextStyle(
    fontFamily: headlineFont,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 64 / 57,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: headlineFont,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: headlineFont,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 28 / 22,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0.25,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 16 / 11,
    letterSpacing: 0.5,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double gutter = 16;
  static const double marginMobile = 16;
  static const double marginTablet = 24;
}

class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double full = 9999;
}
