import 'package:flutter/material.dart';
import 'package:json_visual_editor/ui/json_list.dart';
import 'json_key_value.dart';

class JsonMap extends StatefulWidget {
  final Map v;
  final String? k;
  final GlobalKey<JsonMapState> stateKey;

  const JsonMap._({
    required this.stateKey,
    required this.v,
    required this.k,
  }) : super(key: stateKey);

  factory JsonMap({required Map v, required String? k}) {
    final stateKey = GlobalKey<JsonMapState>();
    return JsonMap._(stateKey: stateKey, v: v, k: k);
  }

  GlobalKey<JsonMapState> getKey() => stateKey;

  @override
  State<JsonMap> createState() => JsonMapState();
}

class JsonMapState extends State<JsonMap> {
  JsonMap get widget => super.widget;
  late List<Widget> content = create(widget.v);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.map),
      title: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: 1.0
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
      if (value is Map) { l.add(JsonMap(k: key, v: value)); }
      else if (value is List) { l.add(JsonList(v: value, k: key)); }
      else if (value is int || value is double || value is String || value is bool || value == null) { l.add(JsonKeyValue(k: key, v: value, bottomBorder: false)); }
    });

    return l;
  }
  
  Map<String, dynamic> rtn() { 
    Map<String, dynamic> r = {};

    for (dynamic g in content) { // Random variable name
      if (g is JsonKeyValue) {
        r[g.k] = g.v;
      } else if (g is JsonMap || g is JsonList) {
        r[g.k] = g.getKey().currentState!.rtn();
      }
    }

    return r;
  }
}