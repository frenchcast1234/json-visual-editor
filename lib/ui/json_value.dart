import 'package:flutter/material.dart';

class JsonValue extends StatefulWidget {
  final String? k; // key
  final dynamic v; // value

  const JsonValue({
    super.key,
    required this.v,
    this.k = null,
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