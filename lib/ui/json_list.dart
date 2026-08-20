import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'json_value.dart';
import 'json_map.dart';

class JsonList extends StatefulWidget {
  final List v;
  final String? k;
  final GlobalKey<JsonListState> stateKey;

  final void Function(Widget child)? onDelete;

  const JsonList._({
    required this.stateKey,
    required this.v,
    required this.k,
    this.onDelete
  }) : super(key: stateKey);

  factory JsonList({required List v, required String? k, void Function(Widget)? onDelete}) {
    final stateKey = GlobalKey<JsonListState>();
    return JsonList._(stateKey: stateKey, v: v, k: k, onDelete: onDelete);
  }

  GlobalKey<JsonListState> getKey() => stateKey;

  @override
  State<JsonList> createState() => JsonListState();
}

class JsonListState extends State<JsonList> {
  JsonList get widget => super.widget;
  late List<Widget> content = create(widget.v);

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
                    content.add(JsonValue(key: UniqueKey(), v: "new value", onDelete: removeChild));
                  })
                ),
                MenuItem<String>(
                  label: Text("Insert list"),
                  icon: Icon(Icons.add),
                  value: "list",
                  onSelected: (value) => setState(() {
                    content.add(JsonList(v: [], k: null, onDelete: removeChild));
                  }),
                ),
                MenuItem<String>(
                  label: Text("Insert map"),
                  icon: Icon(Icons.add),
                  value: "map",
                  onSelected: (value) => setState(() {
                    content.add(JsonMap(v: {}, k: null, onDelete: removeChild));
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
              color: Colors.black
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
                child: Text(widget.k!),
              ) 
            ],
            Column(
              children: content
            )
          ]
        ),
      )
    );
  }

  List<Widget> create(List m) {
    List<Widget> l = [];

    for (dynamic x in m) {
      if (x is Map) { l.add(JsonMap(v: x, k: null, onDelete: removeChild)); }
      else if (x is List) { l.add(JsonList(v: x, k: null, onDelete: removeChild)); }
      else if (x is int || x is double || x is String || x is bool || x == null) { l.add(JsonValue(key: UniqueKey(), v: x, onDelete: removeChild,)); }
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

  void removeChild(Widget child) => setState(() => content.remove(child));
}