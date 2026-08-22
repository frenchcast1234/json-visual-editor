import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'json_value.dart';
import 'json_map.dart';
import 'package:json_visual_editor/modules/color.dart';

enum CurrentState {
  edit,
  title
}

class JsonList extends StatefulWidget {
  final List v;
  final String? k;
  final GlobalKey<JsonListState> stateKey;
  final VoidCallback unsavedRef;

  final void Function(Widget child)? onDelete;

  const JsonList._({
    required this.stateKey,
    required this.v,
    required this.k,
    required this.unsavedRef,
    this.onDelete
  }) : super(key: stateKey);

  factory JsonList({required List v, required String? k, required void Function() unsavedRef, void Function(Widget)? onDelete}) {
    final stateKey = GlobalKey<JsonListState>();
    return JsonList._(stateKey: stateKey, v: v, k: k, unsavedRef: unsavedRef, onDelete: onDelete);
  }

  GlobalKey<JsonListState> getKey() => stateKey;

  @override
  State<JsonList> createState() => JsonListState();
}

class JsonListState extends State<JsonList> {
  JsonList get widget => super.widget;
  late List<Widget> content = create(widget.v);
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
                    content.add(JsonValue(key: UniqueKey(), v: "new value", unsavedRef: widget.unsavedRef, onDelete: removeChild));
                  })
                ),
                MenuItem<String>(
                  label: Text("Insert list"),
                  icon: Icon(Icons.add),
                  value: "list",
                  onSelected: (value) => setState(() {
                    content.add(JsonList(v: [], k: null, unsavedRef: widget.unsavedRef, onDelete: removeChild));
                  }),
                ),
                MenuItem<String>(
                  label: Text("Insert map"),
                  icon: Icon(Icons.add),
                  value: "map",
                  onSelected: (value) => setState(() {
                    content.add(JsonMap(v: {}, k: null, unsavedRef: widget.unsavedRef, onDelete: removeChild));
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
              ],
              position: details.globalPosition,
              padding: EdgeInsets.all(8.0)
            )
          );
        },
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
        child: Column(
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
                  ? [ SizedBox(height: 16) ]
                  : content
            )
          ]
        ),
      )
    );
  }

  List<Widget> create(List m) {
    List<Widget> l = [];

    for (dynamic x in m) {
      if (x is Map) { l.add(JsonMap(v: x, k: null, unsavedRef: widget.unsavedRef, onDelete: removeChild)); }
      else if (x is List) { l.add(JsonList(v: x, k: null, unsavedRef: widget.unsavedRef, onDelete: removeChild)); }
      else if (x is int || x is double || x is String || x is bool || x == null) { l.add(JsonValue(key: UniqueKey(), v: x, unsavedRef: widget.unsavedRef, onDelete: removeChild,)); }
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
}