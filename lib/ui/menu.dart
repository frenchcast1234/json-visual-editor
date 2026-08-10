import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:json_visual_editor/pages/editor.dart';
import 'package:menu_bar/menu_bar.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final ValueNotifier<String> c = ValueNotifier<String>("{}");
  late final GlobalKey<EditorState> _editorKey = GlobalKey<EditorState>();
  late Editor editor = Editor(key: _editorKey, content: c);
  String? path;

  @override
  Widget build(BuildContext context) {
    return MenuBarWidget(
      barButtons: [
        BarButton(
          text: const Text("File"),
          submenu: SubMenu(
            menuItems: [
              MenuButton(
                text: const Text("Open file"),
                icon: const Icon(Icons.open_in_new),
                onTap: () async {
                  FilePickerResult? result = await FilePicker.pickFiles(
                    allowMultiple: false,
                    type: FileType.custom,
                    allowedExtensions: ["json"],
                  );

                  if (result != null) {
                    PlatformFile file = result.files.first;
                    File f = File(file.path!);
                    String tmp = await f.readAsString();
                    c.value = tmp;
                    path = file.path;
                  }
                },
              ),
              MenuButton(
                text: const Text("Save file"),
                icon: const Icon(Icons.save),
                onTap: () async {
                  var file = File(path ?? "");
                  file.writeAsString(json.encode(_editorKey.currentState?.save()));
                },
              ),
              MenuButton(
                text: const Text("Save as"),
                icon: const Icon(Icons.save_as),
                onTap: () async {
                  if (path == null) return;

                  String? outputFile = await FilePicker.saveFile(
                    dialogTitle: "Please select an output file",
                    fileName: "output.json"
                  );

                  if (outputFile == null) return;

                  var file = File(outputFile);
                  file.writeAsString(json.encode(_editorKey.currentState?.save()));
                }
              )
            ],
          ),
        ),
      ],
      child: editor,
    );
  }
}
