import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:json_visual_editor/pages/editor.dart';
import 'package:json_visual_editor/ui/tab_bar.dart';
import 'package:menu_bar/menu_bar.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late final GlobalKey<TabBarEditorState> _tabBarKey = GlobalKey<TabBarEditorState>();

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
                    _tabBarKey.currentState?.addTab(tmp, file.name, file.path!);
                  }
                },
              ),
              MenuButton(
                text: const Text("Save file"),
                icon: const Icon(Icons.save),
                onTap: () async {
                  print('save');
                  var file = File(_tabBarKey.currentState!.path());
                  file.writeAsString(json.encode(_tabBarKey.currentState?.save()));
                  print(_tabBarKey.currentState?.save());
                },
              ),
              MenuButton(
                text: const Text("Save as"),
                icon: const Icon(Icons.save_as),
                onTap: () async {
                  String? outputFile = await FilePicker.saveFile(
                    dialogTitle: "Please select an output file",
                    fileName: "output.json"
                  );

                  if (outputFile == null) return;

                  var file = File(outputFile);
                  file.writeAsString(json.encode(_tabBarKey.currentState?.save()));
                }
              )
            ],
          ),
        ),
      ],
      child: TabBarEditor(key: _tabBarKey),
    );
  }
}
