import 'dart:io';

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
  String c = "{}";

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
                    setState(() {
                      c = tmp;
                    });
                  }
                },
              ),
              MenuButton(
                text: const Text("Save file"),
                icon: const Icon(Icons.save),
                onTap: () async {},
              ),
            ],
          ),
        ),
      ],
      child: Editor(key: ValueKey(c), content: c),
    );
  }
}
