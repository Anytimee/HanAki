import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

enum AppLocaleCode { id, en, ko, ja }

TextTheme _fontFor(String locale, TextTheme base) {
  switch (locale) {
    case 'ko':
      return GoogleFonts.notoSansKrTextTheme(base);
    case 'ja':
      return GoogleFonts.notoSansJpTextTheme(base);
    default:
      final poppinsHead = GoogleFonts.poppinsTextTheme(base);
      return poppinsHead.copyWith(
        bodyLarge: GoogleFonts.inter(textStyle: poppinsHead.bodyLarge),
        bodyMedium: GoogleFonts.inter(textStyle: poppinsHead.bodyMedium),
        bodySmall: GoogleFonts.inter(textStyle: poppinsHead.bodySmall),
      );
  }
}

ThemeData buildHanakiTheme({
  required bool dark,
  required String localeCode,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: dark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: dark ? const Color(0xFF8B7CF6) : AppColors.primary,
    secondary: AppColors.koreaAccent,
    tertiary: AppColors.japanAccent,
    surface: dark ? AppColors.darkSurface : AppColors.lightSurface,
  );

  var base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
      foregroundColor: scheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: dark ? AppColors.darkCard : AppColors.lightCard,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      selectedColor: AppColors.primary.withValues(alpha: .16),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: dark ? AppColors.darkSurface : Colors.white,
      indicatorColor: AppColors.primary.withValues(alpha: .16),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );

  base = base.copyWith(textTheme: _fontFor(localeCode, base.textTheme));
  return base;
}
