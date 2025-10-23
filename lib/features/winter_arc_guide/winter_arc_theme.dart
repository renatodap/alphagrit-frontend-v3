import 'package:flutter/material.dart';

/// Winter Arc brutalist theme with dark, cold, powerful aesthetic
class WinterArcTheme {
  // Colors
  static const Color black = Color(0xFF0A0A0A);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color darkGray = Color(0xFF2A2A2A);
  static const Color gray = Color(0xFF4A4A4A);
  static const Color lightGray = Color(0xFF9A9A9A);
  static const Color iceBlue = Color(0xFF4A90E2);
  static const Color iceBlueLight = Color(0xFF6BA8F2);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F5);

  // Additional colors for admin and premium features
  static const Color mutedOrange = Color(0xFFFF8C42);
  static const Color bloodRed = Color(0xFFDC143C);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [black, charcoal],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [iceBlue, iceBlueLight],
  );

  // Typography
  static const String fontFamily = 'Inter'; // Can be changed to your preferred font

  static TextStyle get heroTitle => const TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w900,
    color: white,
    letterSpacing: -2,
    height: 1.1,
  );

  static TextStyle get heroTitleMobile => const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: white,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static TextStyle get chapterTitle => const TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    color: white,
    letterSpacing: -1,
    height: 1.2,
  );

  static TextStyle get chapterTitleMobile => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: white,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get sectionTitle => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: white,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle get sectionTitleMobile => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: white,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get subsectionTitle => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: white,
    height: 1.4,
  );

  static TextStyle get subsectionTitleMobile => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: white,
    height: 1.4,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: offWhite,
    height: 1.7,
    letterSpacing: 0.2,
  );

  static TextStyle get bodyLargeMobile => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: offWhite,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: offWhite,
    height: 1.6,
  );

  static TextStyle get bodyMediumMobile => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: offWhite,
    height: 1.5,
  );

  static TextStyle get pullQuote => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: iceBlue,
    fontStyle: FontStyle.italic,
    height: 1.4,
    letterSpacing: -0.5,
  );

  static TextStyle get pullQuoteMobile => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: iceBlue,
    fontStyle: FontStyle.italic,
    height: 1.4,
    letterSpacing: -0.3,
  );

  static TextStyle get buttonText => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: white,
    letterSpacing: 0.5,
  );

  static TextStyle get navText => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: lightGray,
    letterSpacing: 0.3,
  );

  static TextStyle get navTextActive => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: iceBlue,
    letterSpacing: 0.3,
  );

  // Spacing
  static const double spacingXS = 8.0;
  static const double spacingS = 16.0;
  static const double spacingM = 24.0;
  static const double spacingL = 32.0;
  static const double spacingXL = 48.0;
  static const double spacingXXL = 64.0;
  static const double spacingXXXL = 96.0;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopMaxWidth = 1200.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: black.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: iceBlue.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  // Helper method to check if mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // Helper method to check if tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  // Helper method to check if desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingM);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingXL);
    } else {
      return const EdgeInsets.symmetric(horizontal: spacingXL, vertical: spacingXXL);
    }
  }

  // Responsive section padding
  static EdgeInsets responsiveSectionPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(vertical: spacingXL);
    } else {
      return const EdgeInsets.symmetric(vertical: spacingXXXL);
    }
  }
}
