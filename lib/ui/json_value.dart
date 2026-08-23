import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/ui/json_map.dart';
import 'package:json_visual_editor/ui/json_list.dart';

enum CurrentState { title, edit }

class JsonValue extends StatefulWidget {
  dynamic v; // value

  final void Function(Widget child)? onDelete;
  final VoidCallback unsavedRef;
  int index;
  final void Function(int insertIndex, dynamic element) insertRef;

  JsonValue({
    super.key,
    required this.v,
    required this.unsavedRef,
    required this.index,
    required this.insertRef,
    this.onDelete,
  });

  @override
  State<JsonValue> createState() => _JsonValueState();
}

class _JsonValueState extends State<JsonValue> {

  final Map<Type, IconData> iconsType = {
    int: Icons.numbers,
    double: Icons.numbers,
    String: Icons.text_format,
    bool: Icons.animation,
    List: Icons.list,
    Map: Icons.map,
    Null: Icons.close,
  };
  final TextEditingController _controller = TextEditingController();

  late Widget content = Text("${widget.v}");
  CurrentState currentState = CurrentState.title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTapDown: (TapDownDetails details) async {
          showContextMenu<String>(
            context,
            contextMenu: ContextMenu<String>(
              entries: [
                MenuItem<String>(
                  label: Text("Delete element"),
                  icon: Icon(Icons.delete),
                  value: "delete",
                  onSelected: (_) => widget.onDelete?.call(widget),
                ),
                MenuItem<String>.submenu(
                  label: Text("Insert after"),
                  icon: Icon(Icons.delete),
                  items: [
                    MenuItem<String>(
                      label: const Text("Value"),
                      icon: const Icon(Icons.add),
                      value: "insert_after_value",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index+1, JsonValue(v: "value", unsavedRef: widget.unsavedRef, index: widget.index+1, insertRef: widget.insertRef))),
                    ),
                    MenuItem<String>(
                      label: const Text("List"),
                      icon: const Icon(Icons.add),
                      value: "insert_after_list",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index+1, JsonList(k: null, v: ["value"], unsavedRef: widget.unsavedRef, index: widget.index+1, insertRef: widget.insertRef))),
                    ),
                    MenuItem<String>(
                      label: const Text("Map"),
                      icon: const Icon(Icons.add),
                      value: "insert_after_map",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index+1, JsonMap(k: null, v: {"key": "value"}, unsavedRef: widget.unsavedRef, index: widget.index+1, insertRef: widget.insertRef))),
                    ),
                  ],
                  onSelected: (_) => widget.onDelete?.call(widget)
                ),
                MenuItem<String>.submenu(
                  label: Text("Insert before"),
                  icon: Icon(Icons.delete),
                  items: [
                    MenuItem<String>(
                      label: const Text("Value"),
                      icon: const Icon(Icons.add),
                      value: "insert_before_value",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index, JsonValue(v: "value", unsavedRef: widget.unsavedRef, index: widget.index-1, insertRef: widget.insertRef))),
                    ),
                    MenuItem<String>(
                      label: const Text("List"),
                      icon: const Icon(Icons.add),
                      value: "insert_before_list",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index, JsonList(k: null, v: ["value"], unsavedRef: widget.unsavedRef, index: widget.index-1, insertRef: widget.insertRef))),
                    ),
                    MenuItem<String>(
                      label: const Text("Map"),
                      icon: const Icon(Icons.add),
                      value: "insert_before_map",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index, JsonMap(k: null, v: {"key": "value"}, unsavedRef: widget.unsavedRef, index: widget.index-1, insertRef: widget.insertRef))),
                    ),
                  ],
                  onSelected: (_) => widget.onDelete?.call(widget)
                ),
              ],
              position: details.globalPosition,
              padding: EdgeInsets.all(8.0),
            ),
          );
        },
        child: Icon(iconsType[widget.v.runtimeType] ?? Icons.abc),
      ),
      title: content,
      onTap: () => setState(() {
        if (currentState == CurrentState.title) {
          currentState = CurrentState.edit;
          _controller.text = widget.v;
          setState(() {
            content = TextField(
              controller: _controller,
              onSubmitted: (value) => setState(() {
                widget.v = value;
                currentState = CurrentState.title;
                content = Text(widget.v);
                widget.unsavedRef();
              }),
            );
          });
        } else if (currentState == CurrentState.edit) {
          currentState == CurrentState.title;
          setState(() {
            content = Text(widget.v);
          });
        }
      }),
    );
  }
}
