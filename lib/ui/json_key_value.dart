import 'package:flutter/material.dart';

enum CurrentState {
  title,
  edit
}

class JsonKeyValue extends StatefulWidget {
  String k;
  dynamic v;
  final bool bottomBorder;

  JsonKeyValue({
    super.key,
    required this.k,
    required this.v,
    this.bottomBorder = true
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
    return Column(
      children: [
        ListTile(
          leading: Icon(iconsType[widget.v.runtimeType] ?? Icons.abc),
          title: content,
          onTap: _onTap
        ),
        if (widget.bottomBorder) ...[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 1.0
                )
              )
            ),
          )
        ]
      ],
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
            if (int.tryParse(value) != null) { widget.v = int.parse(value); }
            else if (double.tryParse(value) != null) { widget.v = double.parse(value); }
            else if (value == "true") { widget.v = true; }
            else if (value == "false") { widget.v = false; }
            else if (value == "null") { widget.v = null; }
            else { widget.v = value; }
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