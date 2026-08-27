import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_visual_editor/ui/menu.dart';
import 'package:json_visual_editor/ui/tab_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Shortcut extends StatefulWidget {
  final void Function() callback;

  const Shortcut({super.key, required this.callback});

  @override
  State<Shortcut> createState() => ShortcutState();
}

class ShortcutState extends State<Shortcut> {
  final GlobalKey<MenuState> menuKey = GlobalKey<MenuState>();
  SharedPreferences? prefs;

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => prefs = p);
  }

  MenuState? get _menu => menuKey.currentState;
  TabBarEditorState? get _tabBar => _menu?.tabBarKey.currentState;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _loadPrefs();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent) return false;

    final keyboard = HardwareKeyboard.instance;
    final ctrl = keyboard.isControlPressed;
    final shift = keyboard.isShiftPressed;
    final alt = keyboard.isAltPressed;
    final key = e.logicalKey;

    if (ctrl && !alt && key == LogicalKeyboardKey.keyS) {
      _save(asNew: shift);
      return true;
    }
    if (ctrl && !alt && !shift && key == LogicalKeyboardKey.keyO) {
      _open();
      return true;
    }
    if (ctrl && !alt && !shift && key == LogicalKeyboardKey.keyN) {
      _tabBar?.addTab("", "Unsaved", null);
      return true;
    }
    if (ctrl && !alt && !shift && key == LogicalKeyboardKey.keyW) {
      if (!_tabBar!.hasTabs) return false;
      _tabBar?.closeTab(_tabBar!.editorKeys[_tabBar!.tabController.index]);
      return true;
    }
    if (ctrl && !alt && key == LogicalKeyboardKey.tab) {
      final tabBar = _tabBar;
      if (tabBar == null || !tabBar.hasTabs) return false;

      final n = tabBar.editors.length;
      final i = tabBar.tabController.index;
      tabBar.tabController.index = shift ? (i - 1 + n) % n : (i + 1) % n;
      return true;
    }
    if (alt && !ctrl && !shift && key == LogicalKeyboardKey.keyT) {
      widget.callback();
      prefs?.setInt('theme', ((prefs?.getInt('theme') ?? 0) - 1).abs());
      return true;
    }

    return false;
  }

  Future<void> _save({required bool asNew}) async {
    final menu = _menu;
    final tabBar = _tabBar;
    if (menu == null || tabBar == null || !tabBar.hasTabs) return;

    final path = await menu.saveTo(asNew ? null : tabBar.path(), tabBar.save());
    if (path != null) tabBar.markSaved(path);
  }

  Future<void> _open() async {
    final menu = _menu;
    if (menu == null) return;

    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ["json"],
    );
    if (result == null) return;

    PlatformFile file = result.files.first;
    String tmp = await File(file.path!).readAsString();
    _tabBar?.addTab(tmp, file.name, file.path!);
    await menu.pushRecentFile(file.path!);
  }

  @override
  Widget build(BuildContext context) {
    return Menu(key: menuKey, onToggleTheme: widget.callback);
  }
}
