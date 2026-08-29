import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/editor/node_menu.dart';
import 'package:json_visual_editor/editor/node_tile.dart';
import 'package:json_visual_editor/model/document.dart';
import 'package:json_visual_editor/model/json_node.dart';

class Editor extends StatelessWidget {
  final Document document;

  const Editor({
    super.key,
    required this.document
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: document,
      builder: (context, _) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final r = document.root;

    return Scaffold(
      body: r != null
          ? ListView(
            children: [
              NodeTile(node: r, edit: document.edit),
              GestureDetector(
                onSecondaryTapDown: (details) {
                  showContextMenu<void>(
                    context,
                    contextMenu: nodeMenu(
                      r,
                      details.globalPosition,
                      edit: document.edit,
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
                  onPressed: () => document.edit(() => document.root = create({"key": "value"})),
                  label: const Text("Base map"),
                  icon: const Icon(Icons.map),
                ),
                ElevatedButton.icon(
                  onPressed: () => document.edit(() => document.root = create(["value"])),
                  label: const Text("Base list"),
                  icon: const Icon(Icons.list),
                )
              ],
            ),
          )
    );
  }

  JsonNode create(dynamic raw) => JsonNode.fromJson(raw);
}
