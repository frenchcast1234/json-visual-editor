import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/ui/json_key_value.dart';
import 'package:json_visual_editor/ui/json_list.dart';
import 'package:json_visual_editor/ui/json_map.dart';
import 'package:json_visual_editor/ui/json_value.dart';

class Editor extends StatefulWidget {
  final ValueNotifier<String?> content;
  final String? path;
  final VoidCallback unsave;

  const Editor({
    super.key,
    required this.content,
    required this.path,
    required this.unsave
  });

  @override
  State<Editor> createState() => EditorState();

}

class EditorState extends State<Editor> {
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

  dynamic decoded;
  List root = [];
  late bool saved = widget.path != null && widget.path != "";
  
  @override
  void initState() {
    super.initState();
    _load();
    widget.content.addListener(_load);
  }

  @override
  void dispose() {
    widget.content.removeListener(_load);
    super.dispose();
  }

  void _load() {
    final raw = widget.content.value;
    if (raw == "") return;

    dynamic tmp;
    try {
      tmp = json.decode(raw ?? template);
    } on FormatException catch (e) {
      _showError("Invalid JSON: ${e.message}");
      return;
    }

    setState(() {
      if (tmp is Map || tmp is List) decoded = tmp;
      root = create(decoded);
    });
  }

  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: root.isNotEmpty 
          ? ListView(
            children: [
              ...root as List<Widget>,
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
                            root.add(JsonMap(v: {}, k: decoded is Map ? "key" : null, index: root.length, insertRef: insert, unsavedRef: setUnsaved));
                          }),
                        ),
                        MenuItem<String>(
                          label: Text("Add list"),
                          icon: Icon(Icons.add),
                          value: "list",
                          onSelected: (value) => setState(() {
                            root.add(JsonList(v: [], k: decoded is Map ? "key" : null, index: root.length, insertRef: insert, unsavedRef: setUnsaved));
                          }),
                        ),
                        MenuItem<String>(
                          label: Text("Add value"),
                          icon: Icon(Icons.add),
                          value: "value",
                          onSelected: (value) => setState(() {
                            root.add(
                              decoded is Map 
                                  ? JsonKeyValue(k: "key", unsavedRef: setUnsaved, index: root.length, insertRef: insert, v: "value")
                                  : JsonValue(v: "value", unsavedRef: setUnsaved, index: root.length, insertRef: insert)
                            );
                          }),
                        ),
                      ],
                      position: details.globalPosition,
                      padding: EdgeInsets.all(8.0)
                    )
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: double.infinity,
                  height: 120,
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

  List<Widget> create(dynamic m) {
    List<Widget> l = [];
    int i = 0;

    if (m is Map) { // Root
      m.forEach((key, value) {
        if (value is Map) { l.add(JsonMap(v: value, k: key, unsavedRef: setUnsaved, index: i, insertRef: insert, onDelete: removeChild)); }
        if (value is List) { l.add(JsonList(v: value, k: key, unsavedRef: setUnsaved, index: i, insertRef: insert, onDelete: removeChild)); }
        else if (value is int || value is double || value is String || value is bool || value == null) { l.add(JsonKeyValue(key: UniqueKey(), k: key, v: value, unsavedRef: setUnsaved, index: i, insertRef: insert, onDelete: removeChild)); }
        i++;
      });
    } else if (m is List) { // Root
      for (dynamic x in m) {
        if (x is List) { l.add(JsonList(v: x, k: null, unsavedRef: setUnsaved, index: i, insertRef: insert, onDelete: removeChild)); }
        if (x is Map) { l.add(JsonMap(v: x, k: null, unsavedRef: setUnsaved, index: i, insertRef: insert, onDelete: removeChild)); }
        else if (x is int || x is double || x is String || x is bool || x == null) { l.add(JsonValue(key: UniqueKey(), v: x, unsavedRef: setUnsaved, index: i, insertRef: insert, onDelete: removeChild)); }
        i++;
      }
    }

    return l;
  }

  dynamic save() { // Return Map|List
    dynamic r; // r=return
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

  void setUnsaved() {
    saved = false;
    widget.unsave();
  }

  void setSaved() => saved = true;

  void insert(int insertIndex, dynamic element) => setState(() {
    root.insert(insertIndex, element);
    for (int x = root.length - 1; x>insertIndex; x--) {
      root[x].index++;
    }
  });
}