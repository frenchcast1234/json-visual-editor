import 'package:flutter/material.dart';

enum CurrentState {
  title,
  edit
}

class JsonKeyValue extends StatefulWidget {
  String k;
  dynamic v;

  JsonKeyValue({
    super.key,
    required this.k,
    required this.v
  });

  @override
  State<JsonKeyValue> createState() => _JsonKeyValueState();
}

class _JsonKeyValueState extends State<JsonKeyValue> {
  JsonKeyValue get widget => super.widget;

  final Map<Type, IconData> iconsType = {
    int: Icons.numbers,
    double: Icons.numbers,
    String: Icons.text_format,
    bool: Icons.animation,
    List: Icons.list,
    Map: Icons.map,
    Null: Icons.close
  };

  final TextEditingController _controller = TextEditingController();

  late Widget content;
  CurrentState currentState = CurrentState.title;

  @override
  void initState() {
    super.initState();

    content = Text("${widget.k} : ${widget.v}");
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconsType[widget.v.runtimeType] ?? Icons.abc),
      title: content,
      onTap: _onTap
    );
  }

  void _onTap() {
    if (currentState == CurrentState.title) {
      currentState = CurrentState.edit;
      _controller.text = widget.v.toString();
      setState(() {
        content = TextField(
          controller: _controller,
          onSubmitted: (value) => setState(() {
            widget.v = value;
            currentState = CurrentState.title;
            content = Text("${widget.k} : ${widget.v}");
          }),
        );
      });
    } else if (currentState == CurrentState.edit) {
      currentState == CurrentState.title;
      setState(() {
        content = Text("${widget.k} : ${widget.v}");
      });
    }
  }
}