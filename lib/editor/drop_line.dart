import 'package:flutter/material.dart';
import 'package:json_visual_editor/model/json_node.dart';

class DropLine extends StatelessWidget {
  const DropLine({
    super.key,
    required this.parent,
    required this.index,
    required this.edit,
    this.height = 8.0,
  });

  final ContainerNode parent;
  final int index;
  final void Function(VoidCallback) edit;
  final double height;

  bool _accepts(JsonNode n) {
    if (n.contains(parent)) return false;             // dans soi-même ou sa branche
    if (n.parent != parent) return true;              // vient d'un autre parent
    return index != n.index && index != n.index + 1;  // no-op : les bandes qui l'encadrent
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<JsonNode>(
      onWillAcceptWithDetails: (d) => _accepts(d.data),
      onAcceptWithDetails: (d) => edit(() => parent.insert(index, d.data)),
      builder: (context, candidates, _) => Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        color: candidates.isEmpty ? null : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}