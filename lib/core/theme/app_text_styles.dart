import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for Smart Pump 2.0 built on top of Google Fonts' Poppins
/// for headings and Inter for body copy — a friendly yet professional pair
/// that renders Devanagari (Hindi/Marathi) legibly as a fallback.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base(TextStyle style) => GoogleFonts.interTextTheme()
      .bodyMedium!
      .merge(style)
      .copyWith(fontFamilyFallback: const ['NotoSansDevanagari']);

  static TextTheme textTheme(Color onSurface) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
          fontSize: 40, fontWeight: FontWeight.w700, color: onSurface),
      displayMedium: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.w700, color: onSurface),
      headlineLarge: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.w600, color: onSurface),
      headlineMedium: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
      titleLarge: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
      titleSmall: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: onSurface),
      bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: onSurface),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
      labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: onSurface),
      labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600, color: onSurface),
    );
  }
}
