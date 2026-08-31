import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/editor/drop_line.dart';
import 'package:json_visual_editor/editor/node_clipboard.dart';
import 'package:json_visual_editor/editor/node_menu.dart';
import 'package:json_visual_editor/model/json_node.dart';
import 'package:json_visual_editor/theme/color.dart';

enum _Editing { none, key, value }

class NodeTile extends StatefulWidget {
  NodeTile({required this.node, required this.edit, required this.clipboard, required this.dragging}) : super(key: ValueKey(node));

  final JsonNode node;

  final void Function(VoidCallback) edit;

  final NodeClipboard clipboard;

  final ValueNotifier<bool> dragging;

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
        final p = n.parent;
        final taken = p is MapNode ? p[k] : null;
        if (taken != null && taken != n) {
          _report("$k is already used");
        } else {
          widget.edit(() => n.key = k);
        }
      } else if (n is LeafNode) {
        final value = n.type.parse(raw);
        widget.edit(() => n.value = value);
      }
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
      edit: widget.edit,
      editKey: () => _edit(_Editing.key),
      clipboard: widget.clipboard
    ),
  );

  Widget _field() => TextField(
    controller: _controller,
    autofocus: true,
    onSubmitted: _submit,
  );

  Widget _handle() {
    final n = node;
    final icon = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: (details) => _menu(details.globalPosition),
      onTap: n is ContainerNode ? () => setState(() => n.folded = !n.folded) : null,
      child: _TypeIcon(node: n, dragging: widget.dragging),
    );

    if (n.parent == null) return icon;

    return Draggable<JsonNode>(
      data: n,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _feedback(),
      childWhenDragging: Opacity(opacity: 0.3, child: icon),
      onDragStarted: () {
        Tooltip.dismissAllToolTips();
        widget.dragging.value = true;
      },
      onDragEnd: (_) => widget.dragging.value = false,
      child: icon,
    );
  }

  Widget _feedback() {
    final n = node;
    final label = switch (n) {
      LeafNode leaf => leaf.key != null ? "${leaf.key}: ${leaf.text}" : leaf.text,
      MapNode m => m.key ?? "{...}",
      ListNode l => l.key ?? "[...]",
    };

    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(4.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(n.icon, size: 16.0),
            const SizedBox(width: 8.0),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = node;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16.0),
      leading: DragTarget<JsonNode>(
        onWillAcceptWithDetails: (d) => n is ContainerNode && !d.data.contains(n) && d.data != n.children.lastOrNull,
        onAcceptWithDetails: (d) => widget.edit(() {
          final c = n as ContainerNode;
          c.add(d.data);
          c.folded = false;
        }),
        builder: (context, candidates, _) => DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: candidates.isEmpty ? Colors.transparent : Theme.of(context).colorScheme.primary,
            ),
          ),
          child: _handle(),
        ),
      ),
      trailing: n is LeafNode
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (n.key != null) 
                  IconButton(onPressed: () => _edit(_Editing.key), icon: const Icon(Icons.key)),
                IconButton(onPressed: () => _edit(_Editing.value), icon: const Icon(Icons.edit))
              ],
            )
          : null,
      title: switch (n) {
        LeafNode leaf => _leaf(leaf),
        ContainerNode container => _container(container),
      },
      onTap: n is MapNode || n is ListNode ? null : () {},
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
                  DropLine(parent: container, index: 0, edit: widget.edit, height: 48.0)
                else ...[
                  for (final (i, child) in container.children.indexed) ...[
                    DropLine(parent: container, index: i, edit: widget.edit),
                    NodeTile(node: child, edit: widget.edit, clipboard: widget.clipboard, dragging: widget.dragging),
                  ],
                  DropLine(parent: container, index: container.children.length, edit: widget.edit),
                ],
              ],
            ),
    );
  }
}

class _TypeIcon extends StatefulWidget {
  const _TypeIcon({required this.node, required this.dragging});

  final JsonNode node;
  final ValueListenable<bool> dragging;

  @override
  State<_TypeIcon> createState() => _TypeIconState();
}

class _TypeIconState extends State<_TypeIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.node;
    final draggable = n.parent != null;

    return ValueListenableBuilder<bool>(
      valueListenable: widget.dragging,
      builder: (context, dragging, _) {
        final active = draggable && !dragging;

        return MouseRegion(
          cursor: active ? SystemMouseCursors.grab : MouseCursor.defer,
          onEnter: draggable ? (_) => setState(() => _hovered = true) : null,
          onExit: draggable ? (_) => setState(() => _hovered = false) : null,
          child: TooltipVisibility(
            visible: active,
            child: Tooltip(
              message: "Drag and drop",
              child: Icon(active && _hovered ? Icons.drag_indicator : n.icon),
            ),
          ),
        );
      },
    );
  }
}