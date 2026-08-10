import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_visual_editor/ui/json_key_value.dart';
import 'package:json_visual_editor/ui/json_list.dart';
import 'package:json_visual_editor/ui/json_map.dart';
import 'package:json_visual_editor/ui/json_value.dart';

class Editor extends StatefulWidget {
  final ValueNotifier<String?> content;

  Editor({
    super.key,
    required this.content
  });

  @override
  State<Editor> createState() => EditorState();
}

class EditorState extends State<Editor> {
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
  List<Widget> root = [];
  
  @override
  void initState() {
    super.initState();
    
    widget.content.addListener(() {
      setState(() {
        dynamic tmp = json.decode(widget.content.value!);
    
        if (tmp.toString().startsWith("{")) {
          decoded = tmp as Map;
        } else if (tmp.toString().startsWith("[")) {
          decoded = tmp as List;
        }
        root = create(decoded);
      });
    });

    dynamic tmp = json.decode(widget.content.value!);
    
    if (tmp.toString().startsWith("{")) {
      decoded = tmp as Map;
    } else if (tmp.toString().startsWith("[")) {
      decoded = tmp as List;
    }
    root = create(decoded);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.content.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: root
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

  dynamic save() { // Return Map|List
    var r; // r=return
    if (decoded is Map) { r = {}; }
    else if (decoded is List) { r = []; }

    for (dynamic k in root) {
      if (k is JsonMap || k is JsonList) {
        if (r is Map) {
          r[k.k] = k.getKey().currentState?.rtn();
        } else if (r is List) {
          r.add(k.getKey().currentState?.rtn());
        }
      } else if (k is JsonKeyValue && r is Map) {
        r[k.k] = k.v;
      } else if (k is JsonValue && r is List) {
        r.add(k.v);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Panic"),
            duration: Duration(seconds: 3),
          )
        );
      }
    }

    return r;
  }
}