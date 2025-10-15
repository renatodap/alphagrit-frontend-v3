import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GritColors {
  static const red = Color(0xFFFF1A1A);
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const greyDark = Color(0xFF222222);
  static const grey = Color(0xFF666666);
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: GritColors.black,
  colorScheme: const ColorScheme.dark(
    primary: GritColors.red,
    onPrimary: GritColors.white,
    surface: GritColors.greyDark,
    onSurface: GritColors.white,
    secondary: GritColors.white,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.bebasNeue(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.0,
      color: GritColors.white,
    ),
    titleLarge: GoogleFonts.bebasNeue(fontSize: 28, fontWeight: FontWeight.w700),
    bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    bodyMedium: GoogleFonts.inter(fontSize: 14),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: GritColors.black,
    foregroundColor: GritColors.white,
    elevation: 0,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: GritColors.greyDark,
    border: OutlineInputBorder(borderSide: BorderSide(width: 2, color: GritColors.white)),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: GritColors.white)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: GritColors.red)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: GritColors.red,
      foregroundColor: GritColors.white,
      shape: const BeveledRectangleBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800),
    ),
  ),
);

class GritCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GritCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GritColors.greyDark,
        border: Border.all(color: GritColors.white, width: 2),
      ),
      padding: padding,
      child: child,
    );
  }
}

class GritButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool inverted;
  const GritButton({super.key, required this.label, required this.onPressed, this.inverted = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: inverted ? GritColors.white : GritColors.red,
          foregroundColor: inverted ? GritColors.black : GritColors.white,
        ),
        onPressed: onPressed,
        child: Text(label.toUpperCase()),
      ),
    );
  }
}

