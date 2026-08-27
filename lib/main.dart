import 'package:flutter/material.dart';
import 'package:json_visual_editor/modules/color.dart';
import 'dart:core';
import 'package:json_visual_editor/modules/shortcut.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => prefs = p);
    if (p.getInt('theme') == 0) { 
      _themeMode = ThemeMode.light;
    } else if (p.getInt('theme') == 1) {
      _themeMode = ThemeMode.dark;
    }
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  ThemeData _buildTheme(bool light) {
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
      home: Shortcut(callback: _toggleTheme),
    );
  }
}
