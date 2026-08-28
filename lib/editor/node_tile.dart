import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/editor/node_menu.dart';
import 'package:json_visual_editor/model/json_node.dart';
import 'package:json_visual_editor/theme/color.dart';

enum _Editing { none, key, value }

class NodeTile extends StatefulWidget {
  NodeTile({required this.node, required this.changed}) : super(key: ValueKey(node));

  final JsonNode node;

  final VoidCallback changed;

  @override
  State<NodeTile> createState() => _NodeTileState();
}

class _NodeTileState extends State<NodeTile> {
  final _controller = TextEditingController();
  _Editing _editing = _Editing.none;

  JsonNode get node => widget.node;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _edit(_Editing what) {
    final n = node;
    _controller.text = what == _Editing.key ? (n.key ?? "") : (n is LeafNode ? n.text : "");
    setState(() => _editing = what);
  }

  void _submit(String raw) {
    final n = node;
    try {
      if (_editing == _Editing.key) {
        final k = raw.trim();
        if (k.isNotEmpty) n.key = k;
      } else if (n is LeafNode) {
        n.setText(raw);
      }
      widget.changed();
    } on FormatException catch (e) {
      _report(e.message);
    }
    setState(() => _editing = _Editing.none);
  }

  void _report(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
  );

  void _menu(Offset at) => showContextMenu<void>(
    context,
    contextMenu: nodeMenu(
      node,
      at,
      changed: widget.changed,
      editKey: () => _edit(_Editing.key),
    ),
  );

  Widget _field() => TextField(
    controller: _controller,
    autofocus: true,
    onSubmitted: _submit,
  );

  @override
  Widget build(BuildContext context) {
    final n = node;
    return ListTile(
      leading: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTapDown: (details) => _menu(details.globalPosition),
        onTap: n is ContainerNode ? () => setState(() => n.folded = !n.folded) : null,
        child: Icon(n.icon),
      ),
      onTap: n is LeafNode ? () => _edit(_Editing.value) : null,
      title: switch (n) {
        LeafNode leaf => _leaf(leaf),
        ContainerNode container => _container(container),
      },
    );
  }

  Widget _leaf(LeafNode leaf) {
    if (_editing == _Editing.value) return _field();

    return Row(
      children: [
        if (leaf.key != null) ...[
          _editing == _Editing.key
              ? Expanded(child: _field())
              : Text(leaf.key!),
          const Text(": "),
        ],
        Flexible(child: Text(leaf.text, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _container(ContainerNode container) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 1.0, color: Coolors.getDarkColor(context)),
        ),
      ),
      child: container.folded
          ? const Padding(
            padding: EdgeInsets.only(left: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.more_horiz, size: 48.0),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (container.key != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: _editing == _Editing.key ? _field() : Text(container.key!),
                  ),
                if (container.children.isEmpty)
                  const SizedBox(height: 48.0)
                else
                  for (final child in container.children)
                    NodeTile(node: child, changed: widget.changed),
              ],
            ),
    );
  }
}
