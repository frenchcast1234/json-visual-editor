import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/ui/json_map.dart';
import 'package:json_visual_editor/ui/json_list.dart';

enum CurrentState {
  title,
  edit
}

class JsonKeyValue extends StatefulWidget {
  String k;
  dynamic v;

  final void Function(Widget child)? onDelete;
  final VoidCallback unsavedRef;
  int index;
  final void Function(int insertIndex, dynamic element) insertRef;

  JsonKeyValue({
    super.key,
    required this.k,
    required this.v,
    required this.unsavedRef,
    required this.index,
    required this.insertRef,
    this.onDelete
  });

  @override
  State<JsonKeyValue> createState() => _JsonKeyValueState();
}

class _JsonKeyValueState extends State<JsonKeyValue> {
  JsonKeyValue get widget => super.widget;

  final Map<Type, IconData> iconsType = {
    int: Icons.numbers,
    double: Icons.numbers,
    String: Icons.text_format,
    bool: Icons.animation,
    List: Icons.list,
    Map: Icons.map,
    Null: Icons.close
  };

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  late Widget content = Text("${widget.k} : ${widget.v}");
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
                  label: Text("Edit key"),
                  icon: Icon(Icons.edit),
                  value: "edit",
                  onSelected: (_) => setState(() {
                    if (currentState == CurrentState.title) {
                      currentState = CurrentState.edit;
                      _controller2.text = widget.k;
                      var oldk = widget.k;
                      setState(() {
                        content = TextField(
                          controller: _controller2,
                          onSubmitted: (value) => setState(() {
                            widget.k = value.trim().isEmpty ? oldk : value;
                            currentState = CurrentState.title;
                            content = Text("${widget.k} : ${widget.v}");
                            widget.unsavedRef();
                          }),
                        );
                      });
                    } else if (currentState == CurrentState.edit) {
                      currentState == CurrentState.title;
                      setState(() {
                        content = Text("${widget.k} : ${widget.v}");
                      });
                    }
                  })
                ),
                MenuItem<String>(
                  label: Text("Delete element"),
                  icon: Icon(Icons.delete),
                  value: "delete",
                  onSelected: (_) => widget.onDelete?.call(widget)
                ),
                MenuItem<String>.submenu(
                  label: Text("Insert after"),
                  icon: Icon(Icons.delete),
                  items: [
                    MenuItem<String>(
                      label: const Text("Value"),
                      icon: const Icon(Icons.add),
                      value: "insert_after_value",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index+1, JsonKeyValue(k: "key", v: "value", unsavedRef: widget.unsavedRef, index: widget.index+1, insertRef: widget.insertRef))),
                    ),
                    MenuItem<String>(
                      label: const Text("List"),
                      icon: const Icon(Icons.add),
                      value: "insert_after_list",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index+1, JsonList(k: "key", v: ["value"], unsavedRef: widget.unsavedRef, index: widget.index+1, insertRef: widget.insertRef))),
                    ),
                    MenuItem<String>(
                      label: const Text("Map"),
                      icon: const Icon(Icons.add),
                      value: "insert_after_map",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index+1, JsonMap(k: "key", v: {"key": "value"}, unsavedRef: widget.unsavedRef, index: widget.index+1, insertRef: widget.insertRef))),
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
                      onSelected: (value) => setState(() => widget.insertRef(widget.index, JsonKeyValue(k: "key", v: "value", unsavedRef: widget.unsavedRef, index: widget.index-1, insertRef: widget.insertRef))),
                    ),
                    MenuItem<String>(
                      label: const Text("List"),
                      icon: const Icon(Icons.add),
                      value: "insert_before_list",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index, JsonList(k: "key", v: ["value"], unsavedRef: widget.unsavedRef, index: widget.index-1, insertRef: widget.insertRef))),
                    ),
                    MenuItem<String>(
                      label: const Text("Map"),
                      icon: const Icon(Icons.add),
                      value: "insert_before_map",
                      onSelected: (value) => setState(() => widget.insertRef(widget.index, JsonMap(k: "key", v: {"key": "value"}, unsavedRef: widget.unsavedRef, index: widget.index-1, insertRef: widget.insertRef))),
                    ),
                  ],
                  onSelected: (_) => widget.onDelete?.call(widget)
                ),
              ],
              position: details.globalPosition,
              padding: EdgeInsets.all(8.0)
            )
          );
        },
        child: Icon(iconsType[widget.v.runtimeType] ?? Icons.abc)
      ),
      title: content,
      onTap: _onTap
    );
  }

  void _onTap() {
    if (currentState == CurrentState.title) {
      currentState = CurrentState.edit;
      _controller.text = widget.v.toString();
      setState(() {
        content = TextField(
          controller: _controller,
          onSubmitted: (value) => setState(() {
            if (int.tryParse(value) != null) { widget.v = int.parse(value); }
            else if (double.tryParse(value) != null) { widget.v = double.parse(value); }
            else if (value == "true") { widget.v = true; }
            else if (value == "false") { widget.v = false; }
            else if (value == "null") { widget.v = null; }
            else { widget.v = value; }
            currentState = CurrentState.title;
            content = Text("${widget.k} : ${widget.v}");
            widget.unsavedRef();
          }),
        );
      });
    } else if (currentState == CurrentState.edit) {
      currentState == CurrentState.title;
      setState(() {
        content = Text("${widget.k} : ${widget.v}");
      });
    }
  }
}