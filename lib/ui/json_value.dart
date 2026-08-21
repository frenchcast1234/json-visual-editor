import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

enum CurrentState {
  title,
  edit
}

class JsonValue extends StatefulWidget {
  dynamic v; // value

  final void Function(Widget child)? onDelete;
  final VoidCallback unsavedRef;

  JsonValue({
    super.key,
    required this.v,
    required this.unsavedRef,
    this.onDelete
  });

  @override
  State<JsonValue> createState() => _JsonValueState();
}

class _JsonValueState extends State<JsonValue> {
  @override
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
  final TextEditingController _controller = TextEditingController();

  late Widget content = Text("${widget.v}");
  CurrentState currentState = CurrentState.title;

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
                  label: Text("Delete element"),
                  icon: Icon(Icons.delete),
                  value: "delete",
                  onSelected: (_) => widget.onDelete?.call(widget),
                ),
              ],
              position: details.globalPosition,
              padding: EdgeInsets.all(8.0)
            )
          );
        },
        child: Icon(iconsType[widget.v.runtimeType] ?? Icons.abc)
      ),
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
            if (int.tryParse(value) != null) { widget.v = int.parse(value); }
            else if (double.tryParse(value) != null) { widget.v = double.parse(value); }
            else if (value == "true") { widget.v = true; }
            else if (value == "false") { widget.v = false; }
            else if (value == "null") { widget.v = null; }
            else { widget.v = value; }
            
            currentState = CurrentState.title;
            content = Text("${widget.v}");
            widget.unsavedRef();
          }),
        );
      });
    } else if (currentState == CurrentState.edit) {
      currentState == CurrentState.title;
      setState(() {
        content = Text("${widget.v}");
      });
    }
  }
}