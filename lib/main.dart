import 'package:flutter/material.dart';
import 'package:json_visual_editor/app/shell.dart';
import 'package:json_visual_editor/storage/settings.dart';
import 'package:json_visual_editor/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp(settings: await Settings.load()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.settings});

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(light: true),
        darkTheme: buildTheme(light: false),
        themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
        home: Shell(settings: settings),
      ),
    );
  }
}
