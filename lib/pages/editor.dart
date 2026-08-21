import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/ui/json_key_value.dart';
import 'package:json_visual_editor/ui/json_list.dart';
import 'package:json_visual_editor/ui/json_map.dart';
import 'package:json_visual_editor/ui/json_value.dart';
import 'package:json_visual_editor/modules/color.dart';

class Editor extends StatefulWidget {
  final ValueNotifier<String?> content;
  final String? path;

  Editor({
    super.key,
    required this.content,
    required this.path,
  });

  @override
  State<Editor> createState() => EditorState();
}

class EditorState extends State<Editor> {
  Editor get widget => super.widget;

  /// Chemin courant du fichier : null tant qu'il n'a jamais ete enregistre.
  late String? _path = widget.path;

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

    print(root);
    
    widget.content.addListener(() => setState(() {
      dynamic tmp = widget.content.value == null ? json.decode(template) : json.decode(widget.content.value!);

      if (widget.content.value == "") return;
    
      if (tmp.toString().startsWith("{")) {
        decoded = tmp as Map;
      } else if (tmp.toString().startsWith("[")) {
        decoded = tmp as List;
      }
      root = create(decoded);
    }));

    setState(() {
      if (widget.content.value == "") return;

      dynamic tmp = widget.content.value == null ? json.decode(template) : json.decode(widget.content.value!);
      if (tmp.toString().startsWith("{")) {
        decoded = tmp as Map;
      } else if (tmp.toString().startsWith("[")) {
        decoded = tmp as List;
      }
      root = create(decoded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: root.isNotEmpty 
          ? ListView(
            children: [
              ...root,
              GestureDetector(
                onSecondaryTapDown: (details) {
                  showContextMenu<String>(
                    context, 
                    contextMenu: ContextMenu<String>(
                      entries: [
                        MenuItem<String>(
                          label: Text("Add map"),
                          icon: Icon(Icons.add),
                          value: "map",
                          onSelected: (value) => setState(() {
                            root.add(JsonMap(v: {}, k: decoded is Map ? "key" : null));
                          }),
                        ),
                        MenuItem<String>(
                          label: Text("Add list"),
                          icon: Icon(Icons.add),
                          value: "list",
                          onSelected: (value) => setState(() {
                            root.add(JsonList(v: [], k: decoded is Map ? "key" : null));
                          }),
                        ),
                        MenuItem<String>(
                          label: Text("Add value"),
                          icon: Icon(Icons.add),
                          value: "value",
                          onSelected: (value) => setState(() {
                            root.add(
                              decoded is Map 
                                  ? JsonKeyValue(k: "key", v: "value")
                                  : JsonValue(v: "value")
                            );
                          }),
                        ),
                      ],
                      position: details.globalPosition,
                      padding: EdgeInsets.all(8.0)
                    )
                  );
                },
                child: Builder(
                  builder: (context) => Container(
                    width: double.infinity,
                    height: 120,
                    color: Coolors.getSurfaceColor(context),
                  ),
                ),
              )
            ],
          )
          : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    decoded = {"key": "value"};
                    root = create(decoded);
                  }), 
                  label: const Text("Base map"),
                  icon: const Icon(Icons.map),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    decoded = ["value"];
                    root = create(decoded);
                  }), 
                  label: const Text("Base list"),
                  icon: const Icon(Icons.list),
                )
              ],
            ),
          )
    );
  }

  List<Widget> create(var m) {
    List<Widget> l = [];

    if (m is Map) { // Root
      m.forEach((key, value) {
        if (value is Map) { l.add(JsonMap(v: value, k: key, onDelete: removeChild)); }
        if (value is List) { l.add(JsonList(v: value, k: key, onDelete: removeChild)); }
        else if (value is int || value is double || value is String || value is bool || value == null) { l.add(JsonKeyValue(key: UniqueKey(), k: key, v: value, onDelete: removeChild)); }
      });
    } else if (m is List) { // Root
      for (dynamic x in m) {
        if (x is List) { l.add(JsonList(v: x, k: null, onDelete: removeChild)); }
        if (x is Map) { l.add(JsonMap(v: x, k: null, onDelete: removeChild)); }
        else if (x is int || x is double || x is String || x is bool || x == null) { l.add(JsonValue(key: UniqueKey(), v: x, onDelete: removeChild)); }
      }
    }

    return l;
  }

  dynamic save() { // Return Map|List
    var r; // r=return
    if (decoded is Map) { r = {}; }
    else if (decoded is List) { r = []; }

    for (dynamic k in root) {
      if (k is JsonMap || k is JsonList) {
        final s = k.getKey().currentState!;
        if (r is Map) {
          r[s.getk()] = s.rtn();
        } else if (r is List) {
          r.add(s.rtn());
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

  String? path() {
    return _path;
  }

  void setPath(String path) {
    _path = path;
  }

  void removeChild(Widget child) => setState(() => root = List.of(root)..remove(child));
}