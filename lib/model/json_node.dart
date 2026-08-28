import 'package:flutter/material.dart';
import 'package:json_visual_editor/model/json_type.dart';

sealed class JsonNode {
  JsonNode({this.key});
  String? key;
  ContainerNode? parent;

  int get index => parent?.children.indexOf(this) ?? 0;
  IconData get icon;
  dynamic toJson();
  JsonNode copy();

  void detach() => parent?.remove(this);

  static JsonNode fromJson(dynamic v, {String? key}) => switch (v) {
    Map m => MapNode.fromJson(m, key: key),
    List l => ListNode.fromJson(l, key: key),
    _ => LeafNode(v, key: key),
  };
}

abstract class ContainerNode extends JsonNode {
  ContainerNode({super.key});
  final List<JsonNode> children = [];
  bool folded = false;

  void adopt(JsonNode child);  
  void insert(int i, JsonNode child) {
    final from = children.indexOf(child);
    if (from >= 0 && from < i) i--; 
    child.detach();
    adopt(child);
    child.parent = this;
    children.insert(i.clamp(0, children.length), child);
  }
  void add(JsonNode child) => insert(children.length, child);
  void addAll(Iterable<JsonNode> nodes) => nodes.toList().forEach(add);

  bool remove(JsonNode child) {
    if (!children.remove(child)) return false;
    child.parent = null;
    return true;
  }
}

class MapNode extends ContainerNode {
  MapNode({super.key});
  @override IconData get icon => Icons.map;

  factory MapNode.fromJson(Map m, {String? key}) => MapNode(key: key)..addAll(m.entries.map((e) => JsonNode.fromJson(e.value, key: "${e.key}")));

  @override void adopt(JsonNode child) => child.key ??= freeKey();

  @override Map<String, dynamic> toJson() => { for (final c in children) c.key!: c.toJson() };
  @override MapNode copy() => MapNode(key: key)..folded = folded..addAll(children.map((c) => c.copy()));

  JsonNode? operator [](String k) => children.where((c) => c.key == k).firstOrNull;

  String freeKey([String base = "key"]) {
    final taken = {for (final c in children) c.key};
    if (!taken.contains(base)) return base;
    var i = 2;
    while (taken.contains("$base$i")) { i++; }
    return "$base$i";
  }

  Set<String> duplicateKeys() {
    final seen = <String>{}, dups = <String>{};
    for (final c in children) { if (!seen.add(c.key!)) dups.add(c.key!); }
    return dups;
  }
}

class ListNode extends ContainerNode {
  ListNode({super.key});
  @override IconData get icon => Icons.list;

  factory ListNode.fromJson(List l, {String? key}) => ListNode(key: key)..addAll(l.map((v) => JsonNode.fromJson(v)));

  @override void adopt(JsonNode child) => child.key = null;

  @override List<dynamic> toJson() => [for (final c in children) c.toJson()];
  @override ListNode copy() => ListNode(key: key)..folded = folded..addAll(children.map((c) => c.copy()));

  JsonNode operator [](int i) => children[i];
}

class LeafNode extends JsonNode {
  LeafNode(dynamic value, {super.key, JsonType? type}) : _type = type ?? JsonType.of(value), _value = value;
  dynamic _value;
  JsonType _type;

  dynamic get value => _value;
  JsonType get type => _type;

  set value(dynamic v) { _value = v; _type = JsonType.of(v); }

  set type(JsonType t) {
    if (t == _type) return;
    _value = t.coerce(_value);
    _type = t;
  }

  String get text => _type.format(_value);
  void setText(String raw) => _value = _type.parse(raw);

  @override IconData get icon => switch (_type) {
    JsonType.string => Icons.text_format,
    JsonType.integer || JsonType.decimal => Icons.numbers,
    JsonType.boolean => Icons.animation,
    JsonType.nil => Icons.close,
  };
  @override dynamic toJson() => _value;
  @override LeafNode copy() => LeafNode(_value, key: key, type: _type);
}

