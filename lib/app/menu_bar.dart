import 'package:flutter/material.dart';
import 'package:json_visual_editor/app/shell.dart';
import 'package:json_visual_editor/storage/json_file.dart';
import 'package:menu_bar/menu_bar.dart';

class AppMenuBar extends StatelessWidget {
  const AppMenuBar({super.key, required this.actions, required this.child});

  final EditorActions actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final recent = actions.settings.recentFiles;

    return MenuBarWidget(
      barButtons: [
        BarButton(
          text: const Text("File"),
          submenu: SubMenu(
            menuItems: [
              MenuButton(
                text: const Text("Open file"),
                icon: const Icon(Icons.open_in_new),
                shortcutText: "CTRL+O",
                onTap: actions.openFile,
              ),
              MenuButton(
                text: const Text("Open recent file"),
                icon: const Icon(Icons.history),
                submenu: SubMenu(
                  menuItems: recent.isEmpty
                      ? [MenuButton(text: const Text("No recent file"))]
                      : [
                          for (final path in recent)
                            MenuButton(
                              text: Text(nameOf(path)),
                              onTap: () => actions.openPath(path),
                            ),
                        ],
                ),
              ),
              MenuButton(
                text: const Text("Save file"),
                icon: const Icon(Icons.save),
                shortcutText: "CTRL+S",
                onTap: actions.save,
              ),
              MenuButton(
                text: const Text("Save as"),
                icon: const Icon(Icons.save_as),
                shortcutText: "CTRL+SHIFT+S",
                onTap: () => actions.save(asNew: true),
              ),
              MenuButton(
                text: const Text("New JSON file"),
                icon: const Icon(Icons.note_add),
                shortcutText: "CTRL+N",
                onTap: actions.newFile,
              ),
            ],
          ),
        ),
        BarButton(
          text: const Text("Edit"),
          submenu: SubMenu(
            menuItems: [
              MenuButton(
                text: const Text("Undo"),
                icon: const Icon(Icons.undo),
                shortcutText: "CTRL+Z",
                onTap: actions.undo,
              ),
              MenuButton(
                text: const Text("Redo"),
                icon: const Icon(Icons.redo),
                shortcutText: "CTRL+Y",
                onTap: actions.redo,
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
                shortcutText: "ALT+T",
                onTap: actions.toggleTheme,
              ),
            ],
          ),
        ),
      ],
      child: child,
    );
  }
}
