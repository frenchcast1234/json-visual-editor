import 'package:flutter/services.dart';
import 'package:json_visual_editor/app/shell.dart';

class AppShortcuts {
  AppShortcuts(this.actions);

  final EditorActions actions;

  void attach() => HardwareKeyboard.instance.addHandler(_onKey);
  void detach() => HardwareKeyboard.instance.removeHandler(_onKey);

  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent) return false;

    final keyboard = HardwareKeyboard.instance;
    final ctrl = keyboard.isControlPressed;
    final shift = keyboard.isShiftPressed;
    final alt = keyboard.isAltPressed;
    final key = e.logicalKey;

    if (alt && !ctrl && !shift && key == LogicalKeyboardKey.keyT) {
      actions.toggleTheme();
      return true;
    }

    if (!ctrl || alt) return false;

    if (key == LogicalKeyboardKey.keyS) {
      actions.save(asNew: shift);
      return true;
    }
    if (key == LogicalKeyboardKey.tab) {
      if (!actions.hasTabs) return false;
      actions.cycleTab(shift ? -1 : 1);
      return true;
    }

    if (shift) return false;

    if (key == LogicalKeyboardKey.keyO) {
      actions.openFile();
      return true;
    }
    if (key == LogicalKeyboardKey.keyN) {
      actions.newFile();
      return true;
    }
    if (key == LogicalKeyboardKey.keyW) {
      if (!actions.hasTabs) return false;
      actions.closeCurrentTab();
      return true;
    }

    return false;
  }
}
