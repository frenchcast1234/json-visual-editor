import 'package:flutter/material.dart';

/// Palette de l'application, en deux variantes (claire / sombre).
///
/// Roles :
///   primary   : accent principal (indicateur d'onglet, elements actifs)
///   dark      : encre, c'est a dire texte et icones poses sur `surface`
///               (donc une couleur *claire* dans le theme sombre)
///   surface   : fond principal de l'editeur
///   accent    : accent secondaire (icones de type, valeurs)
///   highlight : fond de selection / survol
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

  static Map<String, Color> Current(bool t) => t ? lightThemeColors : darkThemeColors;

  static Color getPrimaryColor(bool t) => Current(t)["primary"]!;
  static Color getDarkColor(bool t) => Current(t)["dark"]!;
  static Color getSurfaceColor(bool t) => Current(t)["surface"]!;
  static Color getAccentColor(bool t) => Current(t)["accent"]!;
  static Color getHighlightColor(bool t) => Current(t)["highlight"]!;
}
