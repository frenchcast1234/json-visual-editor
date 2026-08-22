import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:json_visual_editor/ui/json_list.dart';
import 'package:json_visual_editor/ui/json_key_value.dart';
import 'package:json_visual_editor/modules/color.dart';

class JsonMap extends StatefulWidget {
  final Map v;
  final String? k;
  final GlobalKey<JsonMapState> stateKey;
  final VoidCallback unsavedRef;

  final void Function(Widget child)? onDelete;

  const JsonMap._({
    required this.stateKey,
    required this.v,
    required this.k,
    required this.unsavedRef,
    this.onDelete,
  }) : super(key: stateKey);

  factory JsonMap({required Map v, required String? k, required void Function() unsavedRef, void Function(Widget)? onDelete}) {
    final stateKey = GlobalKey<JsonMapState>();
    return JsonMap._(stateKey: stateKey, v: v, k: k, unsavedRef: unsavedRef, onDelete: onDelete);
  }

  GlobalKey<JsonMapState> getKey() => stateKey;

  @override
  State<JsonMap> createState() => JsonMapState();
}

class JsonMapState extends State<JsonMap> {
  JsonMap get widget => super.widget;
  late List<Widget> content = create(widget.v);
  late String k = widget.k ?? "key";

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
                    content.add(JsonKeyValue(key: UniqueKey(), v: "new value", k: "new key", unsavedRef: widget.unsavedRef, onDelete: removeChild));
                  })
                ),
                MenuItem<String>(
                  label: Text("Insert list"),
                  icon: Icon(Icons.add),
                  value: "list",
                  onSelected: (value) => setState(() {
                    content.add(JsonList(v: [], k: "key", unsavedRef: widget.unsavedRef, onDelete: removeChild));
                  }),
                ),
                MenuItem<String>(
                  label: Text("Insert map"),
                  icon: Icon(Icons.add),
                  value: "map",
                  onSelected: (value) => setState(() {
                    content.add(JsonMap(v: {}, k: "key", unsavedRef: widget.unsavedRef, onDelete: removeChild));
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   width: double.infinity,
            //   decoration: BoxDecoration(
            //     border: Border(
            //       top: BorderSide(
            //         width: 1.0
            //       )
            //     )
            //   ),
            // ),
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
      ),
    );
  }

  List<Widget> create(Map m) {
    List<Widget> l = [];

    m.forEach((key, value) {
      if (value is Map) { l.add(JsonMap(k: key, v: value, unsavedRef: widget.unsavedRef, onDelete: removeChild)); }
      else if (value is List) { l.add(JsonList(v: value, k: key, unsavedRef: widget.unsavedRef, onDelete: removeChild)); }
      else if (value is int || value is double || value is String || value is bool || value == null) { l.add(JsonKeyValue(key: UniqueKey(), k: key, v: value, unsavedRef: widget.unsavedRef, onDelete: removeChild)); }
    });

    return l;
  }
  
  Map<String, dynamic> rtn() { 
    Map<String, dynamic> r = {};

    for (dynamic g in content) { // Random variable name
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
}