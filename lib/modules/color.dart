import 'package:flutter/material.dart';

class Coolors {

  static Map<String, Color> lightThemeColors = {
    "primary": Color(0xFF2461D0),
    "dark": Color(0xFF10151F),
    "surface": Color(0xFFF7F9FC),
    "accent": Color(0xFF0A7268),
    "highlight": Color(0xFFDCE7FA)
  };
  static Map<String, Color> darkThemeColors = {
    "primary": Color(0xFF6AA6FF),
    "dark": Color(0xFFE6EAF2),
    "surface": Color(0xFF121721),
    "accent": Color(0xFF4CC2B4),
    "highlight": Color(0xFF22304A)
  };

  static Map<String, Color> current(bool t) => t ? lightThemeColors : darkThemeColors;

  static Map<String, Color> of(BuildContext context) => current(Theme.of(context).brightness == Brightness.light);

  static Color getPrimaryColor(BuildContext context) => of(context)["primary"]!;
  static Color getDarkColor(BuildContext context) => of(context)["dark"]!;
  static Color getSurfaceColor(BuildContext context) => of(context)["surface"]!;
  static Color getAccentColor(BuildContext context) => of(context)["accent"]!;
  static Color getHighlightColor(BuildContext context) => of(context)["highlight"]!;
}
