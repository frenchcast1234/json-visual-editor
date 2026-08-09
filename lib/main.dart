import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(fontFamily: "CascadiaMono"),
      home: Menu(),
    );
  }
}
