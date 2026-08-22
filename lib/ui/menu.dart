import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:json_visual_editor/ui/tab_bar.dart';
import 'package:menu_bar/menu_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menu extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const Menu({super.key, this.onToggleTheme});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late final GlobalKey<TabBarEditorState> _tabBarKey =
      GlobalKey<TabBarEditorState>();
  SharedPreferences? prefs;
  final _fileName = RegExp(r'[^/\\]+$');

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => prefs = p);
  }

  Future<void> _pushRecentFile(String path) async {
    final p = prefs;
    if (p == null) return;

    final recent = [
      path,
      ...?p.getStringList("recent_files")?.where((e) => e != path),
    ];
    await p.setStringList("recent_files", recent);
    if (!mounted) return;
    setState(() {});
  }

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
                    await _pushRecentFile(file.path!);
                  }
                },
              ),
              MenuButton(
                text: const Text("Open recent file"),
                icon: const Icon(Icons.history),
                submenu: SubMenu(
                  menuItems: getRecentFiles().isEmpty
                      ? [MenuButton(text: Text("No recent file"))]
                      : getRecentFiles(),
                ),
              ),
              MenuButton(
                text: const Text("Save file"),
                icon: const Icon(Icons.save),
                onTap: () async {
                  final tabBar = _tabBarKey.currentState;
                  if (tabBar == null || !tabBar.hasTabs) return;

                  final path = await saveTo(tabBar.path(), tabBar.save());
                  if (path != null) tabBar.markSaved(path);
                },
              ),
              MenuButton(
                text: const Text("Save as"),
                icon: const Icon(Icons.save_as),
                onTap: () async {
                  final tabBar = _tabBarKey.currentState;
                  if (tabBar == null || !tabBar.hasTabs) return;

                  final path = await saveTo(null, tabBar.save());
                  if (path != null) tabBar.markSaved(path);
                },
              ),
              MenuButton(
                text: const Text("New JSON file"),
                icon: const Icon(Icons.open_in_new),
                onTap: () {
                  _tabBarKey.currentState?.addTab("", "Unsaved", null);
                },
              ),
            ],
          ),
        ),
        BarButton(
          text: const Text("View"),
          submenu: SubMenu(
            menuItems: [
              MenuButton(
                text: const Text("Toggle theme"),
                icon: const Icon(Icons.brightness_6),
                onTap: () => widget.onToggleTheme?.call(),
              ),
            ],
          ),
        ),
      ],
      child: TabBarEditor(key: _tabBarKey, saveRef: saveTo),
    );
  }

  List<MenuButton> getRecentFiles() {
    List<MenuButton> s = [];

    for (String x in prefs?.getStringList('recent_files') ?? []) {
      s.add(
        MenuButton(
          text: Text(x),
          onTap: () async {
            File f = File(x);
            String tmp = await f.readAsString();
            _tabBarKey.currentState?.addTab(tmp, nameOf(x), x);
          },
        ),
      );
    }

    return s;
  }

  String nameOf(String path) => _fileName.firstMatch(path)?.group(0) ?? path;
  Future<String?> saveTo(String? p, dynamic cont) async {
    String? path = p;
    final isNew = path == null;

    if (isNew) {
      path = await FilePicker.saveFile(
        dialogTitle: "Please select an output file",
        fileName: "output.json",
      );
      if (path == null) return null;
    }

    await File(path).writeAsString(json.encode(cont));
    if (isNew) await _pushRecentFile(path);

    return path;
  }
}
