import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/editor/node_menu.dart';
import 'package:json_visual_editor/editor/node_tile.dart';
import 'package:json_visual_editor/model/json_node.dart';

class Editor extends StatefulWidget {
  final ValueNotifier<String> content;
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

  JsonNode? root;
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
      tmp = json.decode(raw);
    } on FormatException catch (e) {
      _showError("Invalid JSON: ${e.message}");
      return;
    }

    if (tmp is! Map && tmp is! List) {
      _showError("Root must be a map or a list");
      return;
    }

    setState(() => root = create(tmp));
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
    final r = root;

    return Scaffold(
      body: r != null
          ? ListView(
            children: [
              NodeTile(node: r, changed: changed),
              GestureDetector(
                onSecondaryTapDown: (details) {
                  showContextMenu<void>(
                    context,
                    contextMenu: nodeMenu(
                      r,
                      details.globalPosition,
                      changed: changed,
                      editKey: () {}
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
                  onPressed: () => setState(() => root = create({"key": "value"})),
                  label: const Text("Base map"),
                  icon: const Icon(Icons.map),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() => root = create(["value"])),
                  label: const Text("Base list"),
                  icon: const Icon(Icons.list),
                )
              ],
            ),
          )
    );
  }

  JsonNode create(dynamic raw) => JsonNode.fromJson(raw);

  dynamic save() {
    final r = root?.toJson();
    if (r != null) {
      return r;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nothing to save")
        )
      );
    }

    return null;
  }

  String? path() {
    return _path;
  }

  void setPath(String path) {
    _path = path;
  }

  void changed() => setState(() => setUnsaved());

  void setUnsaved() {
    saved = false;
    widget.unsave();
  }

  void setSaved() => saved = true;
}
