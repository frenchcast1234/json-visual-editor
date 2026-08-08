import 'package:flutter/material.dart';
import 'package:json_visual_editor/ui/json_list.dart';
import 'json_key_value.dart';

class JsonMap extends StatefulWidget {
  final String? k;
  final Map v;

  const JsonMap({
    super.key,
    required this.v,
    required this.k,
  });

  @override
  State<JsonMap> createState() => _JsonMapState();
}

class _JsonMapState extends State<JsonMap> {
  JsonMap get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.map),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.k != null) ... [ Text(widget.k!) ],
          Column(
            children: create(widget.v)
          )
        ]
      ),
    );
  }

  List<Widget> create(Map m) {
    List<Widget> l = [];

    m.forEach((key, value) {
      if (value is Map) { l.add(JsonMap(k: key, v: value)); }
      else if (value is List) { l.add(JsonList(v: value, k: key)); }
      else if (value is int || value is double || value is String || value is bool || value == null) { l.add(JsonKeyValue(k: key, v: value)); }
    });

    return l;
  }
}