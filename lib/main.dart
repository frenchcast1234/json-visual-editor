import 'package:flutter/material.dart';
import 'package:json_visual_editor/modules/color.dart';
import 'package:json_visual_editor/ui/menu.dart';
import 'dart:core';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  ThemeData _buildTheme(bool light) {
    final colors = Coolors.Current(light);

    return ThemeData(
      brightness: light ? Brightness.light : Brightness.dark,
      listTileTheme: ListTileThemeData(
        tileColor: colors["surface"],
        iconColor: colors["accent"],
        textColor: colors["dark"],
      ),
      menuBarTheme: MenuBarThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(colors["surface"]!),
        )
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: colors["surface"],
        labelColor: colors["dark"],
        indicatorColor: colors["primary"],
        overlayColor: WidgetStatePropertyAll<Color>(colors["surface"]!),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: colors["surface"]
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(colors["surface"]!)
        )
      ),
      fontFamily: "CascadiaMono"
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(true),
      darkTheme: _buildTheme(false),
      themeMode: _themeMode,
      home: Menu(onToggleTheme: _toggleTheme),
    );
  }
}
