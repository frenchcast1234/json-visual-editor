import 'package:flutter/material.dart';
import 'json_value.dart';
import 'json_map.dart';

class JsonList extends StatefulWidget {
  final List v;
  final String? k;

  const JsonList({
    super.key,
    required this.v,
    required this.k
  });

  @override
  State<JsonList> createState() => _JsonListState();
}

class _JsonListState extends State<JsonList> {
  JsonList get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.list),
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
              children: create(widget.v)
            )
          ]
        ),
      )
    );
  }

  List<Widget> create(List m) {
    List<Widget> l = [];

    for (dynamic x in m) {
      if (x is Map) { l.add(JsonMap(v: x, k: null)); }
      else if (x is List) { l.add(JsonList(v: x, k: null)); }
      else if (x is int || x is double || x is String || x is bool || x == null) { l.add(JsonValue(v: x, bottomBorder: false,)); }
    }

    return l;
  }
}