import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'json_value.dart';
import 'json_map.dart';
import 'package:json_visual_editor/modules/color.dart';

enum CurrentState {
  edit,
  title,
  folded
}

class JsonList extends StatefulWidget {
  final List v;
  final String? k;
  final GlobalKey<JsonListState> stateKey;
  final VoidCallback unsavedRef;
  int index;

  final void Function(Widget child)? onDelete;
  final void Function(int insertIndex, dynamic element) insertRef;

  JsonList._({
    required this.stateKey,
    required this.v,
    required this.k,
    required this.unsavedRef,
    required this.index,
    required this.insertRef,
    this.onDelete
  }) : super(key: stateKey);

  factory JsonList({required List v, required String? k, required void Function() unsavedRef, required int index, required void Function(int, dynamic) insertRef, void Function(Widget)? onDelete}) {
    final stateKey = GlobalKey<JsonListState>();
    return JsonList._(stateKey: stateKey, v: v, k: k, unsavedRef: unsavedRef, index: index, insertRef: insertRef, onDelete: onDelete);
  }

  GlobalKey<JsonListState> getKey() => stateKey;

  @override
  State<JsonList> createState() => JsonListState();
}

class JsonListState extends State<JsonList> {
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
                    content.add(JsonValue(key: UniqueKey(), v: "new value", unsavedRef: widget.unsavedRef, index: content.length, insertRef: widget.insertRef, onDelete: removeChild));
                  })
                ),
                MenuItem<String>(
                  label: Text("Insert list"),
                  icon: Icon(Icons.add),
                  value: "list",
                  onSelected: (value) => setState(() {
                    content.add(JsonList(v: [], k: null, unsavedRef: widget.unsavedRef, index: content.length, insertRef: widget.insertRef, onDelete: removeChild));
                  }),
                ),
                MenuItem<String>(
                  label: Text("Insert map"),
                  icon: Icon(Icons.add),
                  value: "map",
                  onSelected: (value) => setState(() {
                    content.add(JsonMap(v: {}, k: null, unsavedRef: widget.unsavedRef, index: content.length, insertRef: widget.insertRef, onDelete: removeChild));
                  }),
                ),
                MenuItem<String>(
                  label: Text("Edit key"),
                  icon: Icon(Icons.edit),
                  value: "edit",
                  onSelected: (value) => setState(() {
                    currentState = currentState == CurrentState.title ? CurrentState.edit : CurrentState.title; 
                  }),
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
              padding: EdgeInsets.all(8.0)
            )
          );
        },
        onTapDown: (_) => setState(() => currentState = currentState == CurrentState.folded ? CurrentState.title : CurrentState.folded),
        child: Icon(Icons.list)
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
                        )
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
      )
    );
  }

  List<Widget> create(List m) {
    List<Widget> l = [];
    var i = 0;

    for (dynamic x in m) {
      if (x is Map) { l.add(JsonMap(v: x, k: null, unsavedRef: widget.unsavedRef, index: i, insertRef: insert, onDelete: removeChild)); }
      else if (x is List) { l.add(JsonList(v: x, k: null, unsavedRef: widget.unsavedRef, index: i, insertRef: insert, onDelete: removeChild)); }
      else if (x is int || x is double || x is String || x is bool || x == null) { l.add(JsonValue(key: UniqueKey(), v: x, unsavedRef: widget.unsavedRef, index: i, insertRef: insert, onDelete: removeChild,)); }
      i++;
    }

    return l;
  }

  List<dynamic> rtn() { 
    List<dynamic> r = [];

    for (dynamic g in content) { // Random variable name
      if (g is JsonValue) {
        r.add(g.v);
      } else if (g is JsonMap || g is JsonList) {
        r.add(g.getKey().currentState!.rtn());
      }
    }

    return r;
  }

  String getk() {
    return k;
  }

  void removeChild(Widget child) => setState(() => content.remove(child));
  void insert(int insertIndex, dynamic element) => setState(() {
    content.insert(insertIndex, element);
    for (int x = content.length - 1; x>insertIndex; x--) {
      content[x].index++;
    }
  });
}