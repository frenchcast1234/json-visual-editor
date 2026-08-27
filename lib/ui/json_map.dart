import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/ui/json_list.dart';
import 'package:json_visual_editor/ui/json_key_value.dart';
import 'package:json_visual_editor/modules/color.dart';

enum CurrentState {
  title,
  edit,
  folded
}

class JsonMap extends StatefulWidget {
  final Map v;
  final String? k;
  final GlobalKey<JsonMapState> stateKey;
  final VoidCallback unsavedRef;
  int index;

  final void Function(Widget child)? onDelete;
  final void Function(int insertIndex, dynamic element) insertRef;

  JsonMap._({
    required this.stateKey,
    required this.v,
    required this.k,
    required this.unsavedRef,
    required this.index,
    required this.insertRef,
    this.onDelete,
  }) : super(key: stateKey);

  factory JsonMap({required Map v, required String? k, required void Function() unsavedRef, required int index, required void Function(int, dynamic) insertRef, void Function(Widget)? onDelete}) {
    final stateKey = GlobalKey<JsonMapState>();
    return JsonMap._(stateKey: stateKey, v: v, k: k, unsavedRef: unsavedRef, index: index, insertRef: insertRef, onDelete: onDelete);
  }

  GlobalKey<JsonMapState> getKey() => stateKey;

  @override
  State<JsonMap> createState() => JsonMapState();
}

class JsonMapState extends State<JsonMap> {
  late List content = create(widget.v);
  late String k = widget.k ?? "key";
  CurrentState currentState = CurrentState.title;
  late final TextEditingController _kController = TextEditingController(text: k);

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
                  label: Text("Insert value"),
                  icon: Icon(Icons.add),
                  value: "value",
                  onSelected: (value) => setState(() {
                    content.add(JsonKeyValue(key: UniqueKey(), v: "new value", k: "new key", unsavedRef: widget.unsavedRef, index: content.length, insertRef: insert, onDelete: removeChild));
                  })
                ),
                MenuItem<String>(
                  label: Text("Insert list"),
                  icon: Icon(Icons.add),
                  value: "list",
                  onSelected: (value) => setState(() {
                    content.add(JsonList(v: [], k: "key", unsavedRef: widget.unsavedRef, index: content.length, insertRef: insert, onDelete: removeChild));
                  }),
                ),
                MenuItem<String>(
                  label: Text("Insert map"),
                  icon: Icon(Icons.add),
                  value: "map",
                  onSelected: (value) => setState(() {
                    content.add(JsonMap(v: {}, k: "key", unsavedRef: widget.unsavedRef, index: content.length, insertRef: insert, onDelete: removeChild));
                  }),
                ),
                MenuItem<String>(
                  label: Text("Edit key"),
                  icon: Icon(Icons.edit),
                  value: "edit",
                  onSelected: (_) => setState(() {
                    currentState = currentState == CurrentState.title ? CurrentState.edit : CurrentState.title;
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
        onTapDown: (_) => setState(() => currentState = currentState == CurrentState.folded ? CurrentState.title : CurrentState.folded),
        child: Icon(Icons.map)
      ),
      title: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: 1.0,
              color: Coolors.getDarkColor(context)
            )
          )
        ),
        child: currentState != CurrentState.folded
            ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.k != null) ... [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: currentState == CurrentState.title
                        ? Text(k)
                        : TextField(
                          controller: _kController,
                          onSubmitted: (value) => setState(() {
                            var oldk = k;
                            k = value.trim().isEmpty ? oldk : value;
                            currentState = CurrentState.title;
                            widget.unsavedRef();
                          }),
                        ),
                  )
                ],
                Column(
                  children: content.isEmpty
                      ? [ SizedBox(height: 48.0) ]
                      : content as List<Widget>
                )
              ]
            )
            : Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.more_horiz, size: 48.0)
              )
            )
      ),
    );
  }

  List<Widget> create(Map m) {
    List<Widget> l = [];
    var i = 0;

    m.forEach((key, value) {
      if (value is Map) { l.add(JsonMap(k: key, v: value, unsavedRef: widget.unsavedRef, index: i, insertRef: insert, onDelete: removeChild)); }
      else if (value is List) { l.add(JsonList(v: value, k: key, unsavedRef: widget.unsavedRef, index: i, insertRef: insert, onDelete: removeChild)); }
      else if (value is int || value is double || value is String || value is bool || value == null) { l.add(JsonKeyValue(key: UniqueKey(), k: key, v: value, unsavedRef: widget.unsavedRef, index: i, insertRef: insert, onDelete: removeChild)); }
      i++;
    });

    return l;
  }
  
  Map<String, dynamic> rtn() { 
    Map<String, dynamic> r = {};

    for (dynamic g in content) {
      if (g is JsonKeyValue) {
        r[g.k] = g.v;
      } else if (g is JsonMap) {
        final s = g.getKey().currentState!;
        r[s.getk()] = s.rtn();
      } else if (g is JsonList) {
        final s = g.getKey().currentState!;
        r[s.getk()] = s.rtn();
      }
    }

    return r;
  }

  void removeChild(Widget child) => setState(() => content.remove(child));
  
  String getk() {
    return k;
  }

  void insert(int insertIndex, dynamic element) => setState(() {
    content.insert(insertIndex, element);
    for (int x = content.length - 1; x>insertIndex; x--) {
      content[x].index++;
    }
  });
}