import 'package:json_visual_editor/model/json_node.dart';

class NodeClipboard {
  JsonNode? _node;

  void copyNode(JsonNode n) => _node = n.copy();
  JsonNode? get getNode => _node?.copy();
  bool get isEmpty => _node == null;
}