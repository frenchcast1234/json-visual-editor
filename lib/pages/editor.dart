import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_visual_editor/ui/json_key_value.dart';
import 'package:json_visual_editor/ui/json_list.dart';
import 'package:json_visual_editor/ui/json_map.dart';
import 'package:json_visual_editor/ui/json_value.dart';

class Editor extends StatefulWidget {
  String? content;

  Editor({
    super.key,
    required this.content
  });

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  Editor get widget => super.widget;

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

  var decoded;
  
  @override
  void initState() {
    super.initState();
    print("print");
    widget.content = widget.content ?? template;

    dynamic tmp = json.decode(widget.content!);
    
    if (tmp.toString().startsWith("{")) {
      decoded = tmp as Map;
    } else if (tmp.toString().startsWith("[")) {
      decoded = tmp as List;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: create(decoded)
      )
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

    if (l.isEmpty) l.add(Center(child: Text("JSON is empty.")));

    return l;
  }
}