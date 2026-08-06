import 'package:flutter/material.dart';

class JsonValue extends StatefulWidget {
  final String? k; // key
  final dynamic v; // value
  final String idx; // Index

  const JsonValue({
    super.key,
    required this.v,
    this.k = null,
    required this.idx
  });

  @override
  State<JsonValue> createState() => _JsonValueState();
}

class _JsonValueState extends State<JsonValue> {
  @override
  // TODO: implement widget
  JsonValue get widget => super.widget;

  final Map<Type, IconData> iconsType = {
    int: Icons.numbers,
    double: Icons.numbers,
    String: Icons.text_format,
    bool: Icons.animation,
    List: Icons.list,
    Map: Icons.map,
    Null: Icons.close
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key("${widget.idx}"),
      leading: Icon(iconsType[widget.v.runtimeType] ?? Icons.abc),
      title: Text(
        widget.k == null
            ? "${widget.k} : ${widget.v}"
            : "${widget.v}"
      ),
      onTap: () => {
        print(widget.v.runtimeType)
      }
    );
  }
}