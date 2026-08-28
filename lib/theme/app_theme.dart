import 'package:flutter/material.dart';
import 'package:json_visual_editor/theme/color.dart';

ThemeData buildTheme({required bool light}) {
  final colors = Coolors.current(light);

  return ThemeData(
    brightness: light ? Brightness.light : Brightness.dark,
    scaffoldBackgroundColor: colors["surface"],
    canvasColor: colors["surface"],
    listTileTheme: ListTileThemeData(
      tileColor: colors["surface"],
      iconColor: colors["accent"],
      textColor: colors["dark"],
    ),
    menuBarTheme: MenuBarThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(colors["surface"]!),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: colors["surface"],
      labelColor: colors["dark"],
      indicatorColor: colors["primary"],
      overlayColor: WidgetStatePropertyAll<Color>(colors["surface"]!),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: colors["surface"],
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(colors["surface"]!),
      ),
    ),
    fontFamily: "CascadiaMono",
  );
}
