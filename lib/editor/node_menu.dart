import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/model/json_node.dart';
import 'package:json_visual_editor/editor/node_clipboard.dart';

ContextMenu<void> nodeMenu(JsonNode n, Offset at, {required void Function(VoidCallback) edit, required VoidCallback editKey, required NodeClipboard clipboard}) {
  final p = n.parent;

  MenuItem<void> item(String label, IconData icon, VoidCallback act) => MenuItem<void>(
    label: Text(label), 
    icon: Icon(icon), 
    onSelected: (_) => edit(act)
  );

  List<MenuItem<void>> spawn(void Function(JsonNode) place) => [
    item("Value", Icons.add, () => place(LeafNode("value"))),
    item("List", Icons.list, () => place(ListNode())),
    item("Map", Icons.map, () => place(MapNode())),
    if (!clipboard.isEmpty) 
      item("Paste", Icons.paste, () => place(clipboard.getNode!))
  ];

  return ContextMenu<void>(position: at, padding: const EdgeInsets.all(8.0), entries: [
    if (n is ContainerNode)
      MenuItem<void>.submenu(
        label: const Text("Insert into"), 
        icon: const Icon(Icons.add), 
        items: spawn(n.add)
      ),
    if (p is MapNode) 
      item("Edit key", Icons.edit, editKey),
    if (p != null) ...[
      item("Delete element", Icons.delete, n.detach),
      MenuItem<void>.submenu(
        label: const Text("Insert before"), 
        icon: const Icon(Icons.arrow_upward),
        items: spawn((x) => p.insert(n.index, x))
      ),
      MenuItem<void>.submenu(
        label: const Text("Insert after"), 
        icon: const Icon(Icons.arrow_downward),
        items: spawn((x) => p.insert(n.index + 1, x))
      ),
      MenuItem<void>(
        label: const Text("Copy"),
        icon: const Icon(Icons.copy),
        onSelected: (_) => clipboard.copyNode(n),
      ),
      MenuItem<void>(
        label: const Text("Duplicate"),
        icon: const Icon(Icons.control_point_duplicate),
        onSelected: (_) => edit(() => p.insert(n.index + 1, n.copy())),
      ),
    ],
  ]);
}