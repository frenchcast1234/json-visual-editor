import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:json_visual_editor/model/json_node.dart';

class Document extends ChangeNotifier {
  Document({this.root, this.path}) : saved = path != null && path != "";

  factory Document.parse(String raw, {String? path}) {
    final decoded = json.decode(raw);
    if (decoded is! Map && decoded is! List) {
      throw FormatException("Root must be a map or a list", raw);
    }
    return Document(root: JsonNode.fromJson(decoded), path: path);
  }

  JsonNode? root;
  String? path;
  bool saved;

  static const maxUndo = 50;

  final List<JsonNode> _undo = [];
  final List<JsonNode> _redo = [];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  void edit(VoidCallback mutation) {
    final before = root?.copy();
    mutation();

    if (before != null) {
      _undo.add(before);
      if (_undo.length > maxUndo) _undo.removeAt(0);
      _redo.clear();
    }

    saved = false;
    notifyListeners();
  }

  void undo() {
    if (_undo.isEmpty) return;

    final current = root?.copy();
    root = _undo.removeLast();
    if (current != null) _redo.add(current);

    saved = false;
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;

    final current = root?.copy();
    root = _redo.removeLast();
    if (current != null) _undo.add(current);

    saved = false;
    notifyListeners();
  }

  dynamic toJson() => root?.toJson();

  void markSaved(String p) {
    path = p;
    saved = true;
    notifyListeners();
  }
}
