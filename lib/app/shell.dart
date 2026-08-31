import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:json_visual_editor/app/menu_bar.dart';
import 'package:json_visual_editor/app/shortcuts.dart';
import 'package:json_visual_editor/editor/node_clipboard.dart';
import 'package:json_visual_editor/editor/tab_bar.dart';
import 'package:json_visual_editor/model/document.dart';
import 'package:json_visual_editor/storage/json_file.dart';
import 'package:json_visual_editor/storage/settings.dart';

abstract interface class EditorActions {
  Settings get settings;
  bool get hasTabs;

  Future<void> openFile();
  Future<void> openPath(String path);
  void newFile();
  Future<void> save({bool asNew});
  void closeCurrentTab();
  void cycleTab(int delta);
  void undo();
  void redo();
  Future<void> toggleTheme();
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.settings});

  final Settings settings;

  @override
  State<Shell> createState() => ShellState();
}

class ShellState extends State<Shell> with WidgetsBindingObserver implements EditorActions {
  final tabBarKey = GlobalKey<TabBarEditorState>();
  late final AppShortcuts _shortcuts = AppShortcuts(this);

  final NodeClipboard clipboard = NodeClipboard();

  /// Vrai tant qu'un nœud est en cours de déplacement, où qu'il soit dans l'arbre.
  final ValueNotifier<bool> dragging = ValueNotifier(false);

  TabBarEditorState? get _tabBar => tabBarKey.currentState;

  @override
  Settings get settings => widget.settings;

  @override
  bool get hasTabs => _tabBar?.hasTabs ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shortcuts.attach();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shortcuts.detach();
    dragging.dispose();
    super.dispose();
  }

  @override
  Future<void> openFile() async {
    final path = await pickOpenPath();
    if (path != null) await openPath(path);
  }

  @override
  Future<void> openPath(String path) async {
    final String content;
    try {
      content = await readJson(path);
    } on FileSystemException catch (e) {
      await settings.removeRecent(path);
      _report("Cannot open ${nameOf(path)}: ${e.osError?.message ?? e.message}");
      return;
    }
    final Document document;
    try {
      document = Document.parse(content, path: path);
    } on FormatException catch (e) {
      _report("Invalid JSON in ${nameOf(path)}: ${e.message}");
      return;
    }

    _tabBar?.addTab(document);
    await settings.pushRecent(path);
  }

  @override
  void newFile() => _tabBar?.addTab(Document());

  @override
  Future<void> save({bool asNew = false}) async {
    final document = _tabBar?.current;
    if (document == null) return;

    final path = await write(asNew ? null : document.path, document.toJson());
    if (path != null) document.markSaved(path);
  }

  Future<String?> write(String? path, dynamic content) async {
    final target = path ?? await pickSavePath();
    if (target == null) return null;

    final error = await writeJson(target, content);
    if (error != null) {
      _report("Cannot save ${nameOf(target)}: $error");
      return null;
    }

    if (path == null) await settings.pushRecent(target);
    return target;
  }

  @override
  void closeCurrentTab() {
    final tabBar = _tabBar;
    final document = tabBar?.current;
    if (tabBar == null || document == null) return;
    tabBar.closeTab(document);
  }

  @override
  void cycleTab(int delta) {
    final tabBar = _tabBar;
    if (tabBar == null || !tabBar.hasTabs) return;
    final n = tabBar.documents.length;
    tabBar.tabController.index = (tabBar.tabController.index + delta + n) % n;
  }

  @override
  void undo() => _tabBar?.current?.undo();

  @override
  void redo() => _tabBar?.current?.redo();

  @override
  Future<void> toggleTheme() => settings.toggleTheme();

  void _report(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    final tabBar = _tabBar;
    if (tabBar == null || !tabBar.hasUnsaved) return AppExitResponse.exit;

    final choice = await showDialog<CloseChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Warning"),
        content: const Text("Some tabs are not saved."),
        icon: const Icon(Icons.warning),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(CloseChoice.cancel), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(ctx).pop(CloseChoice.discard), child: const Text("Don't save")),
          TextButton(onPressed: () => Navigator.of(ctx).pop(CloseChoice.save), child: const Text("Save")),
        ],
      ),
    );

    if (choice == null || choice == CloseChoice.cancel) return AppExitResponse.cancel;
    if (choice == CloseChoice.save && !await tabBar.saveAll()) return AppExitResponse.cancel;
    return AppExitResponse.exit;
  }

  @override
  Widget build(BuildContext context) => AppMenuBar(
    actions: this,
    child: TabBarEditor(key: tabBarKey, saveRef: write, clipboard: clipboard, dragging: dragging),
  );
}
