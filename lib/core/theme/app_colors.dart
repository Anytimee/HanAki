import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF6C5CE7);
  static const primaryDark = Color(0xFF5A4BD1);
  // Identitas per kategori — dipakai SectionHeader + TabBar + badge.
  static const anime = Color(0xFFE84393); // 🇯🇵 magenta
  static const drakor = Color(0xFFFD79A8); // 🇰🇷 coral pink
  static const donghua = Color(0xFFE17055); // 🇨🇳 crimson-orange
  static const gold = Color(0xFFFDCB6E);

  // Aliases lama agar file yang belum migrasi tetap kompil.
  static const koreaAccent = drakor;
  static const japanAccent = anime;

  // Dark mode default HanAki.
  static const darkBg = Color(0xFF0F0F0F);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkCard = Color(0xFF1A1A1A);
  static const darkBorder = Color(0xFF2A2A2A);

  static const lightBg = Color(0xFFF6F4FF);
  static const lightSurface = Colors.white;
  static const lightCard = Colors.white;

  static const success = Color(0xFF00B894);
  static const danger = Color(0xFFD63031);
}
