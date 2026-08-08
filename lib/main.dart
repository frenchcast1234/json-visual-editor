import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:core';

import 'ui/json_value.dart';
import 'ui/json_list.dart';
import 'ui/json_map.dart';
import 'ui/json_key_value.dart';

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
[
  "dog",
  "cat",
  "fish",
  [
    1,
    2,
    3,
    4
  ],
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
]
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

    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(fontFamily: "CascadiaMono"),
      home: Scaffold(
        body: ListView(
          children: create(decoded)
        )
      ),
    );
  }

  List<Widget> create(var m) {
    List<Widget> l = [];

    if (m is Map) { // Root
      m.forEach((key, value) {
        if (value is Map) { l.add(JsonMap(v: value, k: key)); }
        if (value is List) { l.add(JsonList(v: value, k: key)); }
        else if (value is int || value is double || value is String || value is bool || value == null) { l.add(JsonKeyValue(k: key, v: value, bottomBorder: false,)); }
      });
    } else if (m is List) { // Root
      for (dynamic x in m) {
        if (x is List) { l.add(JsonList(v: x, k: null)); }
        if (x is Map) { l.add(JsonMap(v: x, k: null)); }
        else if (x is int || x is double || x is String || x is bool || x == null) { l.add(JsonValue(v: x, bottomBorder: false,)); }
      }
    }

    return l;
  }
}
