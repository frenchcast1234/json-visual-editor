import 'package:flutter/material.dart';
import 'package:json_visual_editor/pages/editor.dart';

class TabBarEditor extends StatefulWidget {
  const TabBarEditor({super.key});

  @override
  State<TabBarEditor> createState() => TabBarEditorState();
}

class TabBarEditorState extends State<TabBarEditor> with TickerProviderStateMixin {
  late TabController _tabController = TabController(
    length: editors.length,
    initialIndex: 0, 
    vsync: this
  ); 

  final List<GlobalKey<EditorState>> editorKeys = [];
  final List<Editor> editors = [];
  final List<Text> names = [];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: editors.isEmpty
          ? null
          : AppBar(
            title: null,
            bottom: TabBar(
              controller: _tabController,
              tabs: names.isEmpty ? <Widget>[] : names,
            ),
            toolbarHeight: 0,
          ),
      body: editors.isEmpty 
          ? Center(child: Text("Open a JSON file")) 
          : TabBarView(
            controller: _tabController,
            children: editors,
          ),
    );
  }

  void addTab(String content, String name, String path) {
    setState(() {
      var k = GlobalKey<EditorState>();
      editorKeys.add(k);
      editors.add(Editor(key: k, content: ValueNotifier<String?>(content), path: path));
      names.add(Text(name));

      if (editors.length != _tabController.length) {
        final oldIndex = _tabController.index;
        
        final newIndex = oldIndex >= editors.length
            ? editors.length - 1
            : oldIndex;
        
        _tabController.dispose();
        _tabController = TabController(
          length: editors.length,
          initialIndex: newIndex, 
          vsync: this
        );
      }
    });
  }

  dynamic save() {
    return editorKeys[_tabController.index].currentState!.save();
  }

  String path() {
    return editorKeys[_tabController.index].currentState!.path();
  }
}