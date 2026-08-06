import 'package:flutter/material.dart';
import 'dart:convert';

import 'ui/json_value.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  

  String template = r"""
{
  "one": [
    "tomato",
    "potato",
    "apple", 
    "carot"
  ],
  "two": {
    "a": true,
    "b": false,
    "c": false
  },
  "int": 1,
  "float": 3.14,
  "bool": false,
  "str": "Hello world!",
  "null": null
}
""";

  @override
  Widget build(BuildContext context) {
    dynamic tmp = json.decode(template);
    var decoded;
    if (tmp.toString().startsWith("{")) {
      decoded = tmp as Map;
    } else if (tmp.toString().startsWith("[")) {
      decoded = tmp as List;
    }
    int size = decoded.length;

    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: Scaffold(
        body: ListView(
          children: [
            for (int x=0; x<size; x++) ...[
              JsonValue(
                v: decoded is Map 
                    ? decoded.values.elementAt(x)
                    : decoded[x],
                k: decoded is Map 
                    ? decoded.keys.elementAt(x)
                    : null,
              )
            ]
          ],
        )
      ),
    );
  }
}
